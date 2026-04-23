module ApplicationHelper
  def breadcrumbs(*crumbs)
    content_for :breadcrumbs do
      render partial: "shared/breadcrumbs", locals: { items: crumbs }
    end
  end
end
