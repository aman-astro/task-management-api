Rails.application.routes.draw do
  # Initialize Devise for users (skip default routes, we'll add custom ones)
  devise_for :users, skip: :all
  
  # Clean authentication routes
  devise_scope :user do
    post '/signup', to: 'registrations#create'
    post '/login', to: 'sessions#create'
    delete '/logout', to: 'sessions#destroy'
  end

  # API routes
  namespace :api do
    namespace :v1 do
      resources :projects do
        resources :tasks
      end
      resources :tasks do
        collection do
          get 'all', to: 'tasks#all'
        end
      end
      resources :comments, except: [:index] do
        collection do
          get 'task_id/:task_id', to: 'comments#by_task'
          get 'user_id/:user_id', to: 'comments#by_user'
        end
      end
      resources :users do
        collection do
          post 'forgot_password', to: 'users#forgot_password'
          post 'reset_password', to: 'users#reset_password'
        end
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
