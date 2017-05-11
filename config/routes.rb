Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root <!--  ----------------------------------------------------------------------  -->
<!--  NOTE: Please add the following <META> element to your page <HEAD>.      -->
<!--  If necessary, please modify the charset parameter to specify the        -->
<!--  character set of your HTML page.                                        -->
<!--  ----------------------------------------------------------------------  -->

<META HTTP-EQUIV="Content-type" CONTENT="text/html; charset=UTF-8">

<!--  ----------------------------------------------------------------------  -->
<!--  NOTE: Please add the following <FORM> element to your page.             -->
<!--  ----------------------------------------------------------------------  -->

<form action="https://www.salesforce.com/servlet/servlet.WebToLead?encoding=UTF-8" method="POST">

<input type=hidden name="oid" value="00D28000001JRhP">
<input type=hidden name="retURL" value="http://theinstillery.com">


<label for="first_name">First Name</label><input  id="first_name" maxlength="40" name="first_name" size="20" type="text" required/><br>

<label for="last_name">Last Name</label><input  id="last_name" maxlength="80" name="last_name" size="20" type="text" required/><br>

<label for="mobile">Mobile</label><input  id="mobile" maxlength="40" name="mobile" size="20" type="text" required/><br>

<label for="email">Email</label><input  id="email" maxlength="80" name="email" size="20" type="text" required/><br>

<label for="company">Company</label><input  id="company" maxlength="40" name="company" size="20" type="text" required/><br>

<label for="title">Title</label><input  id="title" maxlength="40" name="title" size="20" type="text" /><br>

<input type="submit" name="submit">

</form>welcome#index'

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
