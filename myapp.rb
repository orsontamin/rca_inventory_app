require 'sinatra'
require 'sinatra/reloader' if development?
require "sinatra/activerecord"
require './models/user'
require './models/admin'

enable :sessions

helpers do
  def log_in(user)
     session[:user_id] = user.id
   end

  def admin_log_in(user)
    session[:admin_id] = user.id
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def admin
    @admin = Admin.find_by(id: session[:admin_id])
  end

  def user_signed_in?
    !current_user.nil?
  end

  def admin_signed_in?
    !admin.nil?
  end
end

# Respond a GET HTTP request to the path /
get '/' do
 erb :index
end

####### ######## ########
####### USERS ##########
####### ######## ########
get '/sign-in' do
  if user_signed_in?
    redirect '/'
  end
  erb :sign_in
end

post '/sign-out' do
  session.clear
  @current_user || @admin = nil
  redirect '/'
end

post '/sign-in' do
  @user = User.find_by(email: params[:email])
  if @user && @user.authenticate(params[:password])
    log_in(@user)
    redirect '/user-dashboard'
  else
    erb :sign_in
  end
end

get '/user-dashboard' do
  if user_signed_in?
    erb :user_dashboard
  else
    redirect '/sign-in'
  end
end

post '/sign-up' do
  @user = User.new
  @user.full_name = params[:full_name]
  @user.email = params[:email]
  @user.password = params[:password]
  @user.password_confirmation = params[:password_confirmation]

  if @user.save
    log_in(@user)
    redirect '/user-dashboard'
  else
    # flash[:alert_warning] = "There was an error in saving your account. Please try again"
    erb :sign_up
  end
end

####### ######## ########
####### ADMIN ##########
####### ######## ########
get '/admin-sign-in' do
  if admin_signed_in?
    redirect '/admin-dashboard'
  else
    erb :admin_sign_in
  end
end

post '/admin-sign-in' do
  @admin = Admin.find_by(email: params[:email])
  if @admin && @admin.authenticate(params[:password])
    admin_log_in(@admin)
    redirect '/admin-dashboard'
  else
    erb :admin_sign_in
  end
end


get '/admin-dashboard' do
  if admin_signed_in?
    erb :admin_dashboard
  else
    redirect '/admin-sign-in'
  end
end

get '/sign-up' do
  if user_signed_in?
    redirect '/'
  else
    @user = User.new
    erb :sign_up
  end
end
