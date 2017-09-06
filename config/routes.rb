Rails.application.routes.draw do
  root 'routes#index'
  resources :routes do
    collection do
      get :index
      post :start
    end
  end
  resources :search, only: [:index]
end
