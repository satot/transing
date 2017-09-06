Rails.application.routes.draw do
  root 'routes#index'
  resources :search, only: [:index]
end
