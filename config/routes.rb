Rails.application.routes.draw do
  root "books#index"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :books, only: [ :index, :show, :new, :create, :destroy ] do
    get :continue, on: :member
  end

  resources :passages, only: [ :show ] do
    post :complete, on: :member
  end

  get "typing_stats", to: "typing_stats#index"

  # Health check for load balancers
  get "up" => "rails/health#show", as: :rails_health_check
end
