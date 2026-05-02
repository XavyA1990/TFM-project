module AdminTenants
  class CourseModulesServices
    def initialize(action, params, repository: CourseModulesRepository, positioning_service: Positioning::ReorderSiblings)
      @action = action
      @params = params
      @repository = repository
      @positioning_service = positioning_service
      @course = params[:course]
      @course_module = params[:course_module] || (repository.find_by_slug_in_course(params[:slug], @course) if params[:slug].present?)
    end

    def call
      return build_course_module if @action == :build
      return get_course_module if @action == :get
      return create if @action == :create
      return update if @action == :update
      return destroy if @action == :destroy

      raise ArgumentError, "Invalid action"
    end

    private

    def build_course_module
      attributes = (@params[:attributes] || {}).to_h.symbolize_keys

      CourseModule.new(
        {
          course: @course,
          status: "draft",
          position: next_position
        }.merge(attributes)
      )
    end

    def get_course_module
      @course_module
    end

    def create
      attributes = service_attributes
      positioned_course_module = nil

      CourseModule.transaction do
        positioned_course_module = @positioning_service.new(
          action: :create,
          record: CourseModule.new(course: @course),
          siblings: sibling_course_modules,
          new_position: attributes[:position]
        ).call

        @course_module = @repository.create(
          attributes.merge(course: @course, position: positioned_course_module.position)
        )

        raise ActiveRecord::Rollback if @course_module.errors.any?
      end

      @course_module
    end

    def update
      attributes = service_attributes
      requested_position = attributes.delete(:position)

      CourseModule.transaction do
        @course_module = @repository.update(@course_module, attributes)

        raise ActiveRecord::Rollback if @course_module.errors.any?

        next unless requested_position.present?

        @course_module = @positioning_service.new(
          action: :update,
          record: @course_module,
          siblings: sibling_course_modules,
          new_position: requested_position
        ).call

        raise ActiveRecord::Rollback if @course_module.errors.any?
      end

      @course_module
    end

    def destroy
      CourseModule.transaction do
        @positioning_service.new(
          action: :destroy,
          record: @course_module,
          siblings: sibling_course_modules
        ).call

        @course_module = @repository.destroy(@course_module)

        raise ActiveRecord::Rollback unless @course_module.destroyed?
      end

      @course_module
    end

    def next_position
      @course.course_modules.maximum(:position).to_i + 1
    end

    def service_attributes
      (@params[:attributes] || {}).to_h.symbolize_keys
    end

    def sibling_course_modules
      @course.course_modules
    end
  end
end
