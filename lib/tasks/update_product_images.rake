require "cloudinary"

namespace :products do
  desc "Update product images in Cloudinary"
  task update_images: :environment do
    Product.find_each do |product|
      next unless product.images.attached?

      product.images.each do |image|
        next if image.metadata["public_id"].present?

        begin
          # Download the image file
          image_file = image.download

          # Upload to Cloudinary
          cloudinary_upload = Cloudinary::Uploader.upload(image_file)

          # Update the image metadata with the Cloudinary public_id
          image.update(metadata: image.metadata.merge(public_id: cloudinary_upload["public_id"]))

          puts "Updated image for product: #{product.name} (Cloudinary public_id: #{cloudinary_upload['public_id']})"
        rescue => e
          puts "Error updating image for product #{product.name}: #{e.message}"
        ensure
          # Clean up the temporary file
          image_file.close
          image_file.unlink
        end
      end
    end
  end
end
