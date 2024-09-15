class ProductsController < ApplicationController
  load_and_authorize_resource except: [ :index, :show ]
  before_action :merchant_or_admin, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]

  def index
    @products = Product.with_attached_images.order(category: :desc)
    @products = @products.where(category: params[:category]) if params[:category].present?
    @products = @products.where("LOWER(name) LIKE ?", "%#{params[:name].downcase}%") if params[:name].present?
  end

  def show
  end

  def new
    @product = current_user.products.new
  end

  def create
    @product = current_user.products.new(product_params)

    if @product.save
      redirect_to products_path, notice: "Product was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to products_path, notice: "Product updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "Product deleted successfully."
  end

  private

  def set_product
    @product = Product.with_attached_images.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :category, images: [])
  end

  def merchant_or_admin
    unless current_user && (current_user.merchant? || current_user.admin?)
      redirect_to root_path, alert: "You must be a merchant or admin to perform this action."
    end
  end
end
