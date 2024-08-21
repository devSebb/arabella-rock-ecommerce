class CartsController < ApplicationController
  before_action :set_cart

  def show
  end

  def add
    product = Product.find(params[:product_id])
    quantity = params[:quantity].present? ? params[:quantity].to_i : 1

    @cart[product.id.to_s] ||= 0
    @cart[product.id.to_s] += quantity

    session[:cart] = @cart
    Rails.logger.debug("After adding, cart session data: #{session[:cart].inspect}")
    update_cart_quantity
    redirect_to cart_path, notice: "Product added to cart."
  end

  def remove
    product_id = params[:product_id].to_s
    @cart.delete(product_id)
    session[:cart] = @cart
    update_cart_quantity
    redirect_to cart_path, notice: "Product removed from cart."
  end

  def update_quantity
    product_id = params[:id]
    quantity = params[:quantity].to_i

    if quantity > 0
      session[:cart][product_id] = quantity
      flash[:notice] = "Quantity updated successfully"
    else
      session[:cart].delete(product_id)
      flash[:notice] = "Item removed from cart"
    end

    update_cart_quantity
    redirect_to cart_path
  end

  private

  def set_cart
    @cart = session[:cart] || {}
    Rails.logger.debug("set_cart called, cart data: #{@cart.inspect}")
  end

  def update_cart_quantity
    total_quantity = @cart.values.sum
    Rails.logger.debug("Updating cart quantity: #{total_quantity}")
    Turbo::StreamsChannel.broadcast_replace_to(
      "cart",
      target: "cart_quantity",
      partial: "shared/cart_quantity",
      locals: { quantity: total_quantity }
    )
  end
end
