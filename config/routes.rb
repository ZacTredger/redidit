Rails.application.routes.draw do
  resources :users
  resources :sessions, only: %i[new create destroy]
  concern :votable do
    resources :votes, only: %i[create destroy update], shallow: true
  end
  resources :posts, except: :index, concerns: :votable do
    resources :comments, only: %i[create destroy], shallow: true, concerns: :votable
  end
  get '/home', to: 'static_pages#home'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/help', to: 'static_pages#help'
  root 'static_pages#home'
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  get '/login', to: 'sessions#new'
  get '/sessions', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get '/posts/:id/comments', to: 'posts#show'
  get '/404', to: 'errors#not_found'
  get '/422', to: 'errors#unacceptable'
  get '/500', to: 'errors#internal_error'
end
