module AdminTenants
  class LessonsServices
    def initialize(action, params, repository: LessonsRepository, positioning_service: Positioning::ReorderSiblings)
      @action = action
      @params = params
      @repository = repository
      @positioning_service = positioning_service
      @course_module = params[:course_module]
      @lesson = params[:lesson] || (repository.find_by_slug_in_course_module(params[:slug], @course_module) if params[:slug].present?)
    end

    def call
      return build_lesson if @action == :build
      return get_lesson if @action == :get
      return create if @action == :create
      return update if @action == :update
      return destroy if @action == :destroy

      raise ArgumentError, "Invalid action"
    end

    private

    def build_lesson
      attributes = (@params[:attributes] || {}).to_h.symbolize_keys

      Lesson.new(
        {
          course_module: @course_module,
          status: "draft",
          lesson_type: "text",
          position: next_position
        }.merge(attributes)
      )
    end

    def get_lesson
      @lesson
    end

    def create
      attributes = service_attributes
      positioned_lesson = nil

      Lesson.transaction do
        positioned_lesson = @positioning_service.new(
          action: :create,
          record: Lesson.new(course_module: @course_module),
          siblings: sibling_lessons,
          new_position: attributes[:position]
        ).call

        @lesson = @repository.create(
          attributes.merge(course_module: @course_module, position: positioned_lesson.position)
        )

        raise ActiveRecord::Rollback if @lesson.errors.any?
      end

      @lesson
    end

    def update
      attributes = service_attributes
      requested_position = attributes.delete(:position)

      Lesson.transaction do
        @lesson = @repository.update(@lesson, attributes)

        raise ActiveRecord::Rollback if @lesson.errors.any?

        next unless requested_position.present?

        @lesson = @positioning_service.new(
          action: :update,
          record: @lesson,
          siblings: sibling_lessons,
          new_position: requested_position
        ).call

        raise ActiveRecord::Rollback if @lesson.errors.any?
      end

      @lesson
    end

    def destroy
      Lesson.transaction do
        @positioning_service.new(
          action: :destroy,
          record: @lesson,
          siblings: sibling_lessons
        ).call

        @lesson = @repository.destroy(@lesson)

        raise ActiveRecord::Rollback unless @lesson.destroyed?
      end

      @lesson
    end

    def next_position
      @course_module.lessons.maximum(:position).to_i + 1
    end

    def service_attributes
      (@params[:attributes] || {}).to_h.symbolize_keys
    end

    def sibling_lessons
      @course_module.lessons
    end
  end
end
