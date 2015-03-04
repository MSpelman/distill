class RenameProductImageToImageFileNameInProducts < ActiveRecord::Migration

  def change
    rename_column :products, :product_image, :image_file_name
  end

end
