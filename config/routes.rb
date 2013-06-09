Quotiful::Application.routes.draw do
  # use_doorkeeper
  mount Resque::Server.new, :at => "/resque"

  devise_for :admins, path: :admin

  resources :admin, only: [:index]
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
    resources :preset_categories, except: [:new, :edit, :update], path: "background-categories"
    resources :users, except: [:new, :create, :show] do
      member do
        post :reactivate
      end
    end
    resources :hashtags, only: [:index, :show]
    resources :posts, only: [:index, :update]
  end

  api vendor_string: "quotiful", default_version: 1 do
    version 1 do
      cache as: 'v1' do
        # ROUTES: api/v1/users
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

        # ROUTES: api/v1/posts
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

        # ROUTES: api/v1/tags
        resources :tags, only: [:show] do
          member do
            get 'recent'
          end
        end

        # ROUTES: api/v1/search
        namespace :search do
          resources :authors, only: [:index]
          resources :posts, only: [:index]
          resources :quotes, only: [:index]
          resources :tags, only: [:index]
          resources :users, only: [:index]
        end

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

  root to: 'api/v1/versions#index'
end
