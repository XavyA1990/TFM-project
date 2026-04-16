Rails.application.routes.draw do
  scope "(:locale)", locale: /en|es/ do
    devise_for :users
    get "up" => "rails/health#show", as: :rails_health_check

    scope "/:tenant_slug" do
      
    end
  end
end
