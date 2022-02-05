require 'sinatra'
require 'sinatra/reloader' if development?

require "sinatra/activerecord"
require './models/user'

enable :sessions

helpers do
  def log_in(user)
    session[:user_id] = user.id
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def user_signed_in?
    !current_user.nil?
  end
end

# Respond a GET HTTP request to the path /
get '/' do
 erb :index
end

get '/sign-in' do
  erb :sign_in
end

post '/sign-in' do
  @user= User.find_by(email: params[:email])
  if @user && @user.authenticate(params[:password])
    log_in(@user)
    redirect '/dashboard'
  else
    erb :sign_in
  end
end

get '/sign-out' do

end

post '/sign-out' do
  session.clear
  @current_user = nil
  redirect '/'
end

get '/dashboard' do
  if user_signed_in?
    erb :dashboard
  else
    redirect '/sign-in'
  end
end

get '/sign-up' do
  @user = User.new
  erb :sign_up
end

post '/sign-up' do
  @user = User.new
  @user.full_name = params[:full_name]
  @user.email = params[:email]
  @user.password = params[:password]
  @user.password_confirmation = params[:password_confirmation]

  if @user.save
    log_in(@user)
    redirect '/dashboard'

  else
    erb :sign_up
  end


end
