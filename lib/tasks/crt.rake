# Class Request Tool rake tasks
namespace :crt do
  namespace :images do

    desc "Rebuild uploaded image versions"
    task :rebuild => :environment do
          
      # Now rebuild existing images
      AttachedImage.all.each do |image_obj|
        next if /default_image/ =~ image_obj.image.to_s
        if image_obj.image.nil?
          puts "Missing file for image #{image_obj.image_url}"
        else
          puts "Rebuilding #{image_obj.image_url}"
          image_obj.image.recreate_versions!
          image_obj.save!
        end
      end
    end

  end
end