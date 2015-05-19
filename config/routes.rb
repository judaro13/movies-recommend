Rails.application.routes.draw do
  root 'user#index'

  resources :user, only: [:index, :show]
  resources :movie, only: [:index, :show]
  resources :stats, only: :index
end
