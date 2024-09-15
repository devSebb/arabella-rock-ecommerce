require "json"
require "cloudinary"

namespace :products do
  desc "Re-upload product images to Cloudinary"
  task reupload_images: :environment do
    # Read the JSON file
    filepath = Rails.root.join("db/products.json")
    products_data = JSON.parse(File.read(filepath))

    products_data.each do |product_data|
      product = Product.find_by(name: product_data["name"])
      next unless product

      if product_data["images"].present?
        product_data["images"].each do |image_file|
          image_path = Rails.root.join("app/assets/images", image_file)
          if File.exist?(image_path)
            begin
              # Upload to Cloudinary
              cloudinary_upload = Cloudinary::Uploader.upload(image_path)

              # Attach the image using the Cloudinary public_id
              product.images.attach(
                io: StringIO.new(cloudinary_upload["secure_url"]),
                filename: File.basename(image_path),
                content_type: "image/png",
                identify: false,
                metadata: { public_id: cloudinary_upload["public_id"] }
              )

              puts "Image re-uploaded for product: #{product.name} (Cloudinary public_id: #{cloudinary_upload['public_id']})"
            rescue => e
              puts "Error re-uploading image for product #{product.name}: #{e.message}"
            end
          else
            puts "Image file not found: #{image_path}"
          end
        end
      end
    end
  end
end
