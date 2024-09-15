require "cloudinary"
require "tempfile"

namespace :products do
  desc "Update product images in Cloudinary"
  task update_images: :environment do
    Product.find_each do |product|
      next unless product.images.attached?

      product.images.each do |image|
        next if image.metadata["public_id"].present?

        begin
          # Download the image content
          image_content = image.download

          # Create a temporary file
          temp_file = Tempfile.new([ "image", File.extname(image.filename.to_s) ])
          temp_file.binmode
          temp_file.write(image_content)
          temp_file.rewind

          # Upload to Cloudinary
          cloudinary_upload = Cloudinary::Uploader.upload(temp_file.path)

          # Update the image metadata with the Cloudinary public_id
          image.update(metadata: image.metadata.merge(public_id: cloudinary_upload["public_id"]))

          puts "Updated image for product: #{product.name} (Cloudinary public_id: #{cloudinary_upload['public_id']})"
        rescue => e
          puts "Error updating image for product #{product.name}: #{e.message}"
        ensure
          # Clean up the temporary file
          temp_file.close
          temp_file.unlink
        end
      end
    end
  end
end
