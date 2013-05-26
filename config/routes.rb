Quotiful::Application.routes.draw do
  # use_doorkeeper
  devise_for :users
  mount Resque::Server.new, :at => "/resque"

  api vendor_string: "quotiful", default_version: 1 do
    version 1 do
      cache as: 'v1' do
        devise_for :users
        
        resources :users, only: [:show] do
          collection do
            post 'email_check'
          end

          member do
            get 'feed'
            get 'follows'
            get 'followed_by', path: 'followed-by'
            get 'requested_by', path: 'requested-by'
            get 'recent'
          end

          resources :relationships, path: :relationship, only: [:index, :create], controller: 'users/relationships'
        end

        resources :posts, only: [:create, :show] do
          collection do
            get 'editors_picks', path: 'editors-picks'
            get 'popular', path: 'popular'
          end

          resources :likes, controller: 'posts/likes', only: [:index, :create] do
            collection do
              delete 'destroy', path: ''
            end
          end

          resources :comments, controller: 'posts/comments', only: [:index, :create, :destroy]
        end

        resources :tags, only: [:show] do
          member do
            get 'search'
            get 'recent'
          end
        end

        namespace :search do
          resources :users, only: [:index]
        end

      end
    end

    # version 2 do
    #   inherit from: 'v1'
    # end
  end
end
