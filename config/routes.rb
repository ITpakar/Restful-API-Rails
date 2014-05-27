Quotiful::Application.routes.draw do
  # use_doorkeeper
  mount Resque::Server.new, :at => "/resque"

  devise_for :admins, path: :admin

  resources :admin, only: [:index]

  resources :posts, only: [:show], path: 'q'

  namespace :users do
    resource :passwords, path: :password, only: [:edit, :update] do
      collection do
        get :complete
      end
    end
  end

  namespace :admin do
    resources :preset_images, except: [:new], path: "background-images" do
      member do
        put :assign
        put :unassign
      end
      collection do
        get :unassigned
      end
    end
    resources :preset_categories, except: [:new, :edit, :update], path: "background-categories" do
      member do
        put :set_primary
      end
    end
    resources :users, except: [:new, :create, :show] do
      collection do
        get :featured
        get :spammers
        get :search
      end
      member do
        post :reactivate
        get :followers
        get :following
        get :posts
        put :suggest
      end
    end
    resources :hashtags, only: [:index, :show]
    resources :posts, only: [:index, :update, :destroy] do
      collection do
        get :flagged
      end
    end
    resources :quotes, only: [:index, :new, :create]
  end

  api vendor_string: "quotiful", default_version: 1 do
    version 1 do
      cache as: 'v1' do
        # ROUTES: api/v1/users
        devise_for :users
        
        resources :users, only: [:show] do
          collection do
            post 'email_check'
            get 'suggested'
          end

          member do
            get 'feed'
            get 'follows'
            get 'followed_by', path: 'followed-by'
            get 'requested_by', path: 'requested-by'
            get 'recent'
            put 'spam'
          end

          resources :collections, only: [:index, :create, :destroy], controller: 'users/collections'
          resources :relationships, path: :relationship, only: [:index, :create], controller: 'users/relationships'
        end

        # ROUTES: api/v1/posts
        resources :posts, only: [:create, :show, :destroy] do
          collection do
            get 'editors_picks', path: 'editors-picks'
            get 'popular', path: 'popular'
          end

          member do
            put 'flag'
          end

          resources :likes, controller: 'posts/likes', only: [:index, :create] do
            collection do
              delete 'destroy', path: ''
            end
          end

          resources :comments, controller: 'posts/comments', only: [:index, :create, :destroy]
        end

        # ROUTES: api/v1/tags
        resources :tags, only: [:show] do
          member do
            get 'recent'
          end
        end

        # ROUTES: api/v1/search
        namespace :search do
          resources :authors, only: [:index] do
            collection do
              get 'random'
            end
          end
          resources :posts, only: [:index]
          resources :quotes, only: [:index] do
            collection do
              get 'random'
            end
          end
          resources :topics, only: [:index]
          resources :tags, only: [:index]
          resources :users, only: [:index] do
            collection do
              get 'facebook'
            end
          end
        end

        resources :authors, only: [:index, :show]
        resources :topics, only: [:index, :show]

        resources :activities, only: [:index]

        # ROUTES: api/v1/backgrounds
        resources :preset_images, path: 'backgrounds/images', only: [:show]
        resources :preset_categories, path: 'backgrounds/categories', only: [:index, :show]

        # ROUTES: api/v1/version
        resources :versions, path: :version, only: [:index]
      end
    end

    # version 2 do
    #   inherit from: 'v1'
    # end
  end

  root to: redirect('http://quotiful.com/') #'api/v1/versions#index'
end
