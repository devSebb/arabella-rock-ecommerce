class Product < ApplicationRecord
  has_many :order_items
  has_many :reviews, dependent: :destroy
  has_many_attached :images
  belongs_to :user

  include PgSearch::Model
  pg_search_scope :search_by_product_attributes,
    against: [ :name, :description ],
    using: {
      tsearch: { prefix: true }
    }
end
