class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  scope :completed, -> { where(status: "paid") }
end
