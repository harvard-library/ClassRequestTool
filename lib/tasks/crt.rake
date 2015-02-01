# Class Request Tool rake tasks
namespace :crt do
  namespace :images do

    desc "Rebuild uploaded image versions"
    task :rebuild => :environment do
      AttachedImage.all.each do |image_obj|
        if image_obj.image_url.blank?
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