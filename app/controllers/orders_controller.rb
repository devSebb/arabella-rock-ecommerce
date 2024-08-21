class OrdersController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  load_and_authorize_resource

  def index
    @orders = if current_user&.admin?
                Order.all
    elsif current_user&.merchant?
                Order.all  # Merchants can read all orders
    else
                current_user&.orders || []
    end
  end

  def show
    # @order is already loaded by load_and_authorize_resource
  end

  def create
    @order = current_user.orders.build(status: "pending")
    @cart = session[:cart] || {}

    authorize! :create, @order

    if @cart.empty?
      redirect_to cart_path, alert: "Your cart is empty. Please add items before checking out."
      return
    end

    if @order.save
      create_order_items
      session[:cart] = nil
      redirect_to @order, notice: "Order was successfully created."
    else
      redirect_to cart_path, alert: "Unable to create order. Please try again."
    end
  rescue => e
    Rails.logger.error "Error creating order: #{e.message}"
    redirect_to cart_path, alert: "An error occurred while creating your order. Please try again."
  end

  private

  def create_order_items
    @cart.each do |product_id, quantity|
      product = Product.find(product_id)
      @order.order_items.create(
        product: product,
        quantity: quantity,
        price: product.price
      )
    end
    @order.update(total: @order.order_items.sum { |item| item.price * item.quantity })
  end
end
