require "json"

filepath = Rails.root.join('db/products.json')
serialized_products = File.read(filepath)
products = JSON.parse(serialized_products)

ActiveRecord::Base.transaction do
  products.each do |params|
    product = Product.create(
      name: params["name"],
      description: params["description"],
      price: params["price"],
      stock: params["stock"]
    )

    if params["images"].present?
      params["images"].each do |image_file|
        image_path = Rails.root.join('app/assets/images', image_file)
        if File.exist?(image_path)
          product.images.attach(
            io: File.open(image_path),
            filename: File.basename(image_path)
          )
          puts "Image attached to #{product.name}: #{image_file}"
        else
          puts "Image not found: #{image_path}"
        end
      end
    end

    puts "#{product.name} created"
  end
end
