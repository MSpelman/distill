Distill::Application.routes.draw do

  # Set default page to home for now
  root :to => "pages#home"

  # Resource routes
  get 'users/new_self'
  resources :users do
    collection do
      get :search
      post "/search" => "users#search_result"
    end
    member do
      get :edit_self
    end
  end
  get 'products/remove_from_cart'
  resources :products do
    member do
      post "" => "products#add_to_cart"
      get :delete_image
    end
    resources :comments do
      member do
        get :approve
      end
    end
  end
  resources :orders do
    member do
      get :cancel
      get :fill
      get :pickup
    end
    resources :order_products
  end
  resource :session, :only => [:new, :create, :destroy]
  resource :page, :only => [:home, :about, :events, :contact, :whiskey_process] do
    get :home
    get :about
    get :events
    get :contact
    get :whiskey_process
  end
  resources :message_types
  get 'messages/user_lookup'
  get 'messages/reply'
  resources :messages do
    resources :recipient_users
    collection do
      get :mailbox_in
      get :mailbox_out
    end
  end
  
  # Set up named routes for login/logout
  get "/login" => "sessions#new", :as => "login"
  get "/logout" => "sessions#destroy", :as => "logout"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
