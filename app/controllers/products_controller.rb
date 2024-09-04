class ProductsController < ApplicationController
  load_and_authorize_resource except: [ :index, :show ]
  before_action :merchant_or_admin, only: [ :new, :create, :edit, :update, :destroy ]

  def index
    @products = Product.all.order(category: :desc)
    @products = @products.where(category: params[:category]) if params[:category].present?
    @products = @products.where("LOWER(name) LIKE ?", "%#{params[:name].downcase}%") if params[:name].present?
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = current_user.products.new
  end

  def create
    @product = Product.new(product_params)

    if params[:product][:images].present?
      @product.images.attach(params[:product][:images])
    end

    if @product.save
      redirect_to products_path, notice: "Product was successfully created."
    else
      render :new
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to products_path, notice: "Product updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to products_path, notice: "Product deleted successfully."
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :user_id, :category)
  end

  def merchant_or_admin
    unless current_user && (current_user.merchant? || current_user.admin?)
      redirect_to root_path, alert: "You must be a merchant or admin to perform this action."
    end
  end
end
