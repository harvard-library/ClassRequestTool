# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Process files as they are uploaded:
  # process :scale => [300, 300]

  def scale(width, height)
    resize_to_limit(width, height)
  end

  # Square version for the front page
  version :welcome_page do
    process :resize_to_fill => [400, 400]
  end

  # Creates a square version to display on the repo page as per design
  version :display, :from_version => :welcome_page do
    process :resize_to_fill => [150, 150]
  end

  # Upload/edit thumbnail
  version :thumb, :from_version => :display do
    process :resize_to_fill => [50, 50]
  end 
  
  # Thumbnail for site banner, which is wide
  version :banner_thumb do
    process :resize_to_fit => [300, 100]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(jpg jpeg gif png)
  end

end
