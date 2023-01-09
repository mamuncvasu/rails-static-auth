Source : Agile Web Development With Rails 6 Chapter-15
==========================================================
```
rails new static_auth && cd static_auth
rails g controller static_page index admin
rails g controller Sessions new create destroy
rails g scaffold User email:string password:digest
rails db:migrate

edit: Gemfile>> gem "bcrypt", "~> 3.1.7"
bundle install
```

Model/User
-------------------------------------
```
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  has_secure_password
end
```
routes: >>
----------------------------------------
```
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
```
-------------------------------------------------------------------
SessionsController
-------------------------------------------------------------------
```
class SessionsController < ApplicationController
  skip_before_action :authorize
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user.try(:authenticate, params[:password])
      session[:user_id] = user.id
      redirect_to admin_url
    else
      redirect_to   login_url, alert:  'Invalid user/password'
    end
  end

  def destroy
    params[:user_id] = nil
    redirect_to login_path, notice: 'Logged Out'
  end
end
```

views/sessions/new   and remove : (destroy and create) view
------------------------------------------------------------------------
```
<section>
<% if flash[:alert] %>
  <%=flash[:alert] %>
<% end %>

<%= form_tag do %>
  <h1>Please Log In</h1>
  <div>
    <%=label_tag :email, 'Email: ' %>
    <%=text_field_tag :email, params[:email] %>
  </div>
  <div>
    <%=label_tag :password, 'Password: ' %>
    <%=password_field_tag :password, params[:name] %>
  </div>
  <div>
    <%=submit_tag "Login" %>
  </div>
<% end %>
</section>
```
------------------------------------------------------------------------------
Edit >> UserController
-------------------------------------------------------------------------------
```
skip_before_action :authorize, only: [:new, :create]
#New Method code same
def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_url, notice: "User #{@user.email} was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_url, notice: "User was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end
  ```
-----------------------------------------------------------------------------------------------
ApplicationController
-----------------------------------------------------------------------------------------------
```
class ApplicationController < ActionController::Base
  before_action :authorize
  private
  def authorize
    unless User.find_by(id: session[:user_id])
      redirect_to login_url, notice: "Please Log in"
    end
  end
end
```
------------------------------------------------------------------------------------------------

layouts/application
------------------------------------------------------------------------------
```
<% if session[:user_id] %>
    <%= button_to 'Log Out', logout_path, method: :delete %>
<% end %>
```
===================================================================================================
```
localhost:3000/register
localhost:3000/login
```
