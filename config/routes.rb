Rails.application.routes.draw do

  root 'welcome#index'

  # get "data" => 'farm_blocks#get_iot_shadow'
  # post "data" => 'farm_blocks#get_iot_shadow'

  get "data" => 'farm_blocks#get_iot_shadows'
  post "data" => 'farm_blocks#get_iot_shadows'

  get "water_tanks/:water_tank_id/data" => 'water_tanks#get_tank_data'
  get "about" => 'welcome#about', :as => "about"
  get "pricing" => "welcome#pricing", :as => "pricing"
  get "blog" => "welcome#blog", :as => "blog"
  get "contact" => "welcome#contact", :as => "contact"
  get "landing" => "welcome#landing", :as => "landing"
  get "users/:user_id/farm_blocks" => "farm_blocks#index", :as => "dashboard"

  post "alert/seen" => "alerts#user_check_alert"
  get "get_all_alerts" => "alerts#get_all_alerts"

  resources :users, only: [:new, :create, :edit, :update, :show], shallow: true  do

    member do
      get :confirm_email
    end

    resources :farm_blocks, shallow: true do
      resources :addresses
      resources :locations

      resources :water_tanks, shallow: true  do
        # resources :sensor_outputs, only:[:create, :index, :stream]
        resources :locations
        resources :alerts
      end

      # resources :meters do
      #   resources :alerts
      # end

      resources :inflow_meters do
        resources :locations
        resources :alerts
      end
    end
  end
  resources :sessions, only: [:create, :destroy]
  get "login" => 'sessions#new', :as => "login"
  get "logout" => 'sessions#destroy', :as => "logout"

  resources :charges

end
