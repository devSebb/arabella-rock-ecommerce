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

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("cart_quantity", partial: "shared/cart_quantity", locals: { quantity: @cart.values.sum }),
          turbo_stream.update("cart_notice", "<div class='notice'>Product added to cart.</div>")
        ]
      end
      format.html { redirect_to cart_path, notice: "Product added to cart." }
    end
  end

  def remove
    product_id = params[:product_id].to_s
    @cart.delete(product_id)
    session[:cart] = @cart

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("cart_quantity", partial: "shared/cart_quantity", locals: { quantity: @cart.values.sum }),
          turbo_stream.update("cart_notice", "<div class='notice'>Product removed from cart.</div>")
        ]
      end
      format.html { redirect_to cart_path, notice: "Product removed from cart." }
    end
  end

  def update_quantity
    product_id = params[:id]
    quantity = params[:quantity].to_i

    if quantity > 0
      session[:cart][product_id] = quantity
    else
      session[:cart].delete(product_id)
    end

    @cart = session[:cart]

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("cart_quantity", partial: "shared/cart_quantity", locals: { quantity: @cart.values.sum }),
          turbo_stream.replace("cart_items", partial: "carts/cart_items", locals: { cart: @cart }),
          turbo_stream.update("cart_notice", "<div class='notice'>Cart updated.</div>")
        ]
      end
      format.html { redirect_to cart_path, notice: "Cart updated." }
    end
  end

  private

  def set_cart
    @cart = session[:cart] || {}
    Rails.logger.debug("set_cart called, cart data: #{@cart.inspect}")
  end
end
