Rails.application.routes.draw do
  scope "(:locale)", locale: /en|es/ do
    devise_for :users, controllers: {
      registrations: "users/registrations",
      sessions: "users/sessions",
    }
    get "up" => "rails/health#show", as: :rails_health_check
    get "/" => "home#index", as: :root 

    namespace :admin do
      resources :tenants
      resources :users, only: [:index, :show] do
        resources :role_assignments, only: [:create], controller: "role_assignments"
      end

    end

    scope "/:tenant_slug" do
      get "/" => "tenants#show", as: :tenant_root

      namespace :admin_tenants do
        resource :tenant, only: [:show, :edit, :update]
        resources :users, only: [:index, :show] do
          resources :role_assignments, only: [:create], controller: "role_assignments"
        end
      end
    end
  end
end
