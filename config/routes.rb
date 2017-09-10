Rails.application.routes.draw do
  root 'routes#index'
  resources :routes do
    collection do
      get :index
      post :start
      get :bus_arrivals_ajax
    end
  end
  resources :search, only: [:index]
end
