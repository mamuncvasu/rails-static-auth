Rails.application.routes.draw do
  get 'signup', to:'users#new'
  get 'login', to:'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  resources :users

  root "static_page#index"
  get 'admin', to: 'static_page#admin'
  get 'user', to: 'static_page#user'
end
