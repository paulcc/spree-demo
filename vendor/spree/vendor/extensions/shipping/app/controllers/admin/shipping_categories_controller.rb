class Admin::ShippingCategoriesController < ApplicationController
  resource_controller
  
  layout 'admin'
  
  update.response do |wants|
    wants.html { redirect_to collection_url }
  end
  
  
  create.response do |wants|
    wants.html { redirect_to collection_url }
  end
  
end
