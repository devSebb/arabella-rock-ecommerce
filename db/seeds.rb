require "json"
require "open-uri"

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
          # Open the file and create a tempfile
          file = File.open(image_path)
          tempfile = Tempfile.new([ File.basename(image_path, ".*"), File.extname(image_path) ])
          tempfile.binmode
          tempfile.write(file.read)
          tempfile.rewind

          # Attach the image using the tempfile
          product.images.attach(
            io: tempfile,
            filename: File.basename(image_path),
            content_type: 'image/png'
          )

          puts "Image attached to #{product.name}: #{image_file}"

          # Close and delete the tempfile
          tempfile.close
          tempfile.unlink
        else
          puts "Image not found: #{image_path}"
        end
      end
    end

    puts "#{product.name} created"
  end
end
