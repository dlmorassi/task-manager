Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "projects#index"

  get "sign_up", to: "registrations#new", as: :sign_up
  post "sign_up", to: "registrations#create"
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout
  resources :members, only: [:index, :create]

  resources :projects, only: [:index, :new, :create, :show] do
    resources :statuses, only: :create do
      member do
        patch :move
      end
    end
    resources :memberships, controller: :project_memberships, only: [:create, :destroy]
    resources :tasks, only: [:create, :show, :update] do
      resources :comments, only: :create
    end
  end
end
