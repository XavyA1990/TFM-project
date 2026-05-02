class LessonsRepository
  def self.find_by_slug_in_course_module(slug, course_module)
    course_module.lessons.friendly.find(slug)
  end

  def self.create(params)
    Lesson.create(params)
  end

  def self.update(lesson, params)
    lesson.update(params)
    lesson
  end

  def self.destroy(lesson)
    lesson.destroy
  end
end
