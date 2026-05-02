module AdminTenants
  class CourseModulesServices
    def initialize(action, params, repository: CourseModulesRepository)
      @action = action
      @params = params
      @repository = repository
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
      @repository.create(@params[:attributes].merge(course: @course))
    end

    def update
      @repository.update(@course_module, @params[:attributes])
    end

    def destroy
      @repository.destroy(@course_module)
    end

    def next_position
      @course.course_modules.maximum(:position).to_i + 1
    end
  end
end
