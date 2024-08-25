class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
    @users = User.includes(:products).all
  end

  def show
    @user = current_user
    @order = @user.orders.find_by(id: params[:id])
    # @products = Product.find_by(merchant_id: @user.id)
  end


  def edit
  end

  def update
  end
end
