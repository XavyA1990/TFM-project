class CourseModulesRepository
  def self.find_by_slug_in_course(slug, course)
    course.course_modules.friendly.find(slug)
  end

  def self.create(params)
    CourseModule.create(params)
  end

  def self.update(course_module, params)
    course_module.update(params)
    course_module
  end

  def self.destroy(course_module)
    course_module.destroy
  end
end
