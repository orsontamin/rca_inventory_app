require 'sinatra'
require 'sinatra/reloader' if development?
require "sinatra/activerecord"
require './models/user'
require './models/admin'
require './models/product'
require './models/booking'

configure do
  enable :sessions
  set :method_override, true
end

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
  else
    erb :sign_in
  end
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
    @bookings = Booking.where(user_id: current_user.id)
    erb :user_dashboard
  else
    redirect '/sign-in'
  end
end

post '/sign-up' do
  @user = User.new(full_name: params[:full_name],
                   email: params[:email],
                   password: params[:password],
                   password_confirmation: params[:password_confirmation])

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
    @bookings = current_user.bookings
    @overdue_bookings = @bookings.is_overdue

    if @overdue_bookings.any?
      erb :overdue
    else
      erb :products_index
    end

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

get '/sign-up' do
  if user_signed_in?
    redirect '/'
  else
    @user = User.new
    erb :sign_up
  end
end

get '/admin-dashboard' do
  if admin_signed_in?
    @bookings = Booking.all
    erb :admin_dashboard
  else
    redirect '/admin-sign-in'
  end
end

get '/admin-dashboard/new-product' do
  @product = Product.new
  erb :new_product
end

post '/admin-dashboard/new-product' do
  @product = Product.new(title: params[:title],
                         description: params[:description],
                         available: params[:available],
                         quantity: params[:quantity])

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

patch '/admin-dashboard/update-booking-status/:id' do
  @booking = Booking.all.find(params[:id])
  if @booking
    update_success = @booking.update(booking_status: params[:booking_status])
    redirect '/admin-dashboard/users'
  end
end

patch '/admin-dashboard/edit-product/:id' do
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

delete '/admin-dashboard/delete-product/:id' do
  @product = Product.find(params[:id])
  if @product.destroy
    redirect '/admin-dashboard'
  else
    'Product cannot be deleted'
    redirect '/admin-dashboard'
  end
end

get '/admin-dashboard/users' do
  if admin_signed_in?
    @bookings = Booking.all
    erb :admin_bookings_index
  else
    redirect '/'
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
  @user = User.find(current_user.id)
  @product = Product.find(params[:id])
  @booking = Booking.new(user_id: current_user.id,
                         product_id: @product.id,
                         quantity: params[:quantity],
                         booking_date: params[:booking_date],
                         return_date: params[:return_date])

  if @booking.save
    redirect 'user-dashboard'
  else
    erb :book_product
  end
end

# def update
#   @product = Product.find(params[:id])
#   @booking = Booking.find(params[:id])
#   @product.decrement_stock(@booking.quantity)
# end
