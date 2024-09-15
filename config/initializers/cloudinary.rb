Cloudinary.config do |config|
  config.cloud_name = ENV["CLOUDINARY_CLOUD_NAME"]
  config.api_key = ENV["CLOUDINARY_API_KEY"]
  config.api_secret = ENV["CLOUDINARY_API_SECRET"]
  config.secure = true

  puts "Cloudinary configuration:"
  puts "Cloud name: #{config.cloud_name}"
  puts "API key: #{config.api_key}"
  puts "API secret: #{config.api_secret ? '[REDACTED]' : 'Not set'}"
end
