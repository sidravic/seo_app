require "memoized.rb"
class CategoriesController < ApplicationController
 before_filter :admin_logged_in?, :except => [:index, :show]

  def index
   @categories = Category.all(:parent_id => nil)
  end

  def show
    @category = Category.first(:slug => params[:id])
   # memoized_categories = memoized_object(@category, 'find_all_subcategories')
   # RAILS_DEFAULT_LOGGER.debug " MEMOIZED OBJECT"  + memoized_categories.object_id.to_s
    @sub_categories = @category.find_all_subcategories
   # @sub_categories = memoized_categories.memoized
  end

  # renders the file upload page
  def new
    @title = "Upload Categories"
  end

  def create
    if params[:upload] && params[:upload][:datafile]
      status, error = Category.save_file(params[:upload][:datafile])
      if status
        flash[:notice] = "Your file has been successfully save"
        redirect_to admin_url(current_admin)    
      else
        flash[:error] = "#{error}"
        render_file_upload_page
      end
    else
      flash[:error] = "Please select a file to upload"
      render_file_upload_page
    end
  end

  def load_categories
    loaded_category_count = Category.initiate_category_load
    loaded_category_count.nil?  ?  message = "0 Categories Loaded" :  message = "#{loaded_category_count} categories loaded" 
    flash[:notice] = message
    redirect_to admin_url(current_admin.id) 
  end

  def load_category_keywords
    status, error =  CategoryKeyword.initiate_category_keyword_upload
    if status
      flash[:notice] = "Category Keywords were successfully loaded" 
    else
      flash[:notice] = error
    end
    redirect_to admin_url(current_admin.id)
  end

  private

  def render_file_upload_page
    render :action => :new
  end
end
