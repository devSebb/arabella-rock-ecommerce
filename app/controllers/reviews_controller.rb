class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [ :new, :create ]
  before_action :check_purchase, only: [ :new, :create ]

  def index
    @reviews = Review.all
  end

  def new
    @product = Product.find(params[:product_id])
  @review = Review.new
  end

  def create
    @review = Review.new(review_params)
    @review.user = current_user
    @review.product = @product

    if @review.save
      redirect_to @product, notice: "Review was successfully created."
    else
      render :new
    end
  end

  def edit
    @review = Review.find(params[:id])
  end

  def update
    @review = Review.find(params[:id])
    if @review.update(review_params)
      redirect_to @review.product, notice: "Review was successfully updated."
    else
      render :edit
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def check_purchase
    unless current_user.orders.completed.joins(:order_items).where(order_items: { product_id: @product.id }).exists?
      redirect_to @product, alert: "You can only review products you have purchased."
    end
  end

  def review_params
    params.require(:review).permit(:comment, :rating)
  end
end
