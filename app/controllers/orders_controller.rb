class OrdersController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  load_and_authorize_resource

  def index
    @orders = if current_user&.admin?
      Order.all
    elsif current_user&.merchant?
      Order.all
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
      render json: { error: "Your cart is empty. Please add items before checking out." }, status: :unprocessable_entity
      return
    end

    if @order.save
      create_order_items
      create_stripe_session
    else
      render json: { error: "Unable to create order. Please try again." }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Error creating order: #{e.message}"
    render json: { error: "An error occurred while creating your order. Please try again." }, status: :internal_server_error
  end

  def success
    @order = Order.find(params[:id])
    @order.update(status: "paid")
    session[:cart] = nil
    redirect_to @order, notice: "Payment successful. Your order has been placed."
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

  def create_stripe_session
    line_items = @order.order_items.map do |item|
      {
        price_data: {
          currency: "usd",
          product_data: {
            name: item.product.name
          },
          unit_amount: (item.price * 100).to_i
        },
        quantity: item.quantity
      }
    end

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: line_items,
      mode: "payment",
      success_url: success_order_url(@order),
      cancel_url: cart_url
    )

    render json: { id: session.id }
  rescue Stripe::StripeError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
