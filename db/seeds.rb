require "json"
require "open-uri"
require "cloudinary"

filepath = Rails.root.join('db/products.json')
serialized_products = File.read(filepath)
products = JSON.parse(serialized_products)

ActiveRecord::Base.transaction do
  products.each do |params|
    product = Product.create(
      name: params["name"],
      description: params["description"],
      price: params["price"],
      stock: params["stock"],
      user_id: params["user_id"],
      category: params["category"]
    )

    if params["images"].present?
      params["images"].each do |image_file|
        image_path = Rails.root.join('app/assets/images', image_file)
        if File.exist?(image_path)
          # Upload to Cloudinary
          cloudinary_upload = Cloudinary::Uploader.upload(image_path)

          # Attach the image using the Cloudinary public_idww
          product.images.attach(
            io: StringIO.new(cloudinary_upload['secure_url']),
            filename: File.basename(image_path),
            content_type: 'image/png',
            identify: false,
            metadata: { public_id: cloudinary_upload['public_id'] }
          )

          puts "Image attached to #{product.name}: #{image_file} (Cloudinary public_id: #{cloudinary_upload['public_id']})"
        else
          puts "Image not found: #{image_path}"
        end
      end
    end

    puts "#{product.name} created"
  end
end
