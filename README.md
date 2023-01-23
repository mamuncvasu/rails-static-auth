Source : Agile Web Development With Rails 6 Chapter-15 -- Ektu Customize korsi
==========================================================
```
rails new static_auth && cd static_auth
rails g controller static_page index admin
rails g controller Sessions new create destroy
rails g scaffold User email:string password:digest role
rails db:migrate

edit: Gemfile>> gem "bcrypt", "~> 3.1.7"
bundle install
```

Model/User
-------------------------------------
```
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
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
  layout 'session'
  skip_before_action :authorize
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user.try(:authenticate, params[:password])
      session[:user_id] = user.id
      session[:role] = user.role
      redirect_to root_path
    else
      redirect_to   login_url, alert:  'Invalid user/password'
    end
  end

  def destroy
    params[:user_id] = nil
    redirect_to login_url, notice: 'Logged Out'
  end
end
```
layout/session.html.erb   / ta na hole loin page e user data dekhay
-----------------------------------------------------------------------
```
<!DOCTYPE html>
<html>
  <head>
    <title>StuMarks</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
    <link rel="stylesheet" href="https://cdn.simplecss.org/simple.css">
  </head>

  <body>
    <div class="center">
      <br><br><br><br>
      <%= yield %>
    </div>
  </body>
</html>

```
--------------------------------------------------------------------------

views/sessions/new   and remove : (destroy and create) view
------------------------------------------------------------------------
```

<article>
  <% if flash[:alert] %>
    <%=flash[:alert] %>
  <% end %>

  <%= form_tag do %>
    <h1>Log In</h1>
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
</article>

```
------------------------------------------------------------------------------
Edit >> UserController    custom : SuperAdmin na hole User create/edit korte dibe na
-------------------------------------------------------------------------------
```
class UsersController < ApplicationController
  # skip_before_action :authorize, only: [:new, :create]
  before_action :set_user, only: %i[ show edit update destroy ]

  # before_action :check_if_superadmin, except: %i[edit update]
  before_action :check_if_superadmin

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to root_path, notice: "User #{@user.email} was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to root_path, notice: "User was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :role)
    end

   def check_if_superadmin
     # superadmin na hole root_path e jabe
     @user = User.find(session[:user_id])
     unless @user.role.to_i == 1
       redirect_to root_path
     end
   end

end

  ```
-----------------------------------------------------------------------------------------------
edit: view/users/_form
------------------------------------------------------------------------------------------------
```
<div>
    <%= form.label :email, style: "display: block" %>
    <%= form.email_field :email %>
  </div>
......
.......
 <div>
    <%= form.label :role, style: "display: block" %>
    <%#= form.text_field :role %>
    <%= form.select :role, [["SuperAdmin", "1"], ["Admin", "2"], ["user", "3"]] %>

  </div>
```
----------------------------------------------------------------------------------------------


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
<!DOCTYPE html>
<html>
  <head>
    <title>StuMarks</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
    <link rel="stylesheet" href="https://cdn.simplecss.org/simple.css">
  </head>

  <body>
      <p>
        <% if session[:user_id] %>
          <%@user = User.find(session[:user_id]) %>
          Email : <%= @user.email %> |
          Role : <%=@user.role.to_i %> |
          <%= button_to 'Log Out', logout_path, method: :delete %>
        <% end %>
      </p>
      <%= yield %>
  </body>
</html>
```
===================================================================================================

edit view/sessions/new
===============================================================================
```
 <%=password_field_tag :password, params[:name] %>
```

Do Before 1st Use
====================================================================================
```
Comment Out UserController >>  skip_before_action :authorize, only: [:new, :create]
for create 1st SuperAdmin  >>localhost:3000/signup
Comment Out UserController Back >> #skip_before_action :authorize, only: [:new, :create]
Now only SuperAdmin can create User
localhost:3000/login
```
Or, Manually Add User
====================================================================================
````
User.create(email: 'admin@gmail.com', password: '123', password_confirmation: '123')
````

