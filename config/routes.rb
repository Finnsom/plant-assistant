Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :plants do
    post :identify, on: :collection
    patch :watered_today, on: :member
    resources :chats, only: [:index, :create]
  end

  resources :chats, only: [:show] do
    resources :messages, only: [:create]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
