class ProductsController < ApplicationController
  load_and_authorize_resource

  def index
    if params[:name].present?
      @products = Product.search_by_product_attributes(params[:name])
    else
      @products = Product.all
    end
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to products_path, notice: "Product created successfully."
    else
      render :new
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :images)
  end
end
