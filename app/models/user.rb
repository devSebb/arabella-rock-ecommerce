class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  #  -> { where(role: "merchant" || "admin") }
  has_many :products
  has_many :orders

  enum role: { customer: "customer", merchant: "merchant", admin: "admin" }
end
