Rails.application.routes.draw do
  scope "(:locale)", locale: /en|es/ do
    devise_for :users
    get "up" => "rails/health#show", as: :rails_health_check
    get "/" => "home#index", as: :root 

    namespace :admin do
      resources :tenants
    end

    scope "/:tenant_slug" do
      get "/" => "tenants#show", as: :tenant_root

      namespace :admin_tenants do
        resource :tenant, only: [:show, :edit, :update]
      end
    end
  end
end
