require 'sinatra'
require 'sinatra/reloader' if development?
require "sinatra/activerecord"
require './models/user'
require './models/admin'
require './models/product'
require './models/booking'

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

  def current_product
    @current_product ||= Product.find_by(id: session[:product_id])
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

get '/products' do
  if user_signed_in?
    @products = Product.all
    erb :products_index
  else
    redirect '/sign-in'
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

get '/admin-dashboard/new-product' do
  @product = Product.new
  erb :new_product
end

post '/admin-dashboard/new-product' do
  @product = Product.new
  @product.title = params[:title]
  @product.description = params[:description]
  @product.available = params[:available]
  @product.quantity = params[:quantity]

  if @product.save
    redirect '/admin-dashboard'
  else
    erb :new_product
  end
end

get '/admin-dashboard/products' do
  if admin_signed_in?
    @products = Product.all
    erb :admin_products_index
  else
    redirect '/admin_sign_in'
  end
end

get '/admin-dashboard/edit-product/:id' do
  @product = Product.find(params[:id])
  if admin_signed_in?
    erb :edit_product
  else
    redirect '/'
  end
end

post '/admin-dashboard/edit-product/:id' do
  @product = Product.find(params[:id])
  if @product
    update_success = @product.update(title: params[:title],
                                     description: params[:description],
                                     available: params[:available] ? 1 : 0,
                                     quantity: params[:quantity])
      if update_success
        redirect '/admin-dashboard'
      else
        redirect '/admin-dashboard/edit-product/:id'
      end
    end
end

post '/admin-dashboard/delete-product/:id' do
  @product = Product.find(params[:id])
  if @product.destroy
    redirect '/admin-dashboard'
  else
    'Product cannot be deleted'
    redirect '/admin-dashboard'
  end
end

####### ######## ########
####### BOOKING ##########
####### ######## ########

get '/product/book/:id' do
  @product = Product.find(params[:id])
  if user_signed_in?
    erb :book_product
  else
    redirect '/'
  end
end

post '/product/book/:id' do
  @product = Product.find(params[:id])
  if user_signed_in?
    erb :book_product
  else
    redirect '/'
  end
end

post '/product/books/:id' do
  @user = User.find(params[:id])
  @product = Product.find(params[:id])
  @booking = Booking.new
  @booking.user_id = @user.id
  @booking.product_id = @product.id
  @booking.quantity = params[:quantity]
  @booking.booking_date = params[:booking_date]
  @booking.return_date = params[:return_date]

  if @booking.save
    redirect 'user-dashboard'
  else
    erb :book_product
  end
end
