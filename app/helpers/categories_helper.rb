module CategoriesHelper

  # checks if the @categories array size is greater than the index of the current category obj passed
  # used for display in the Categories#index method

  def index_within_category_array?(index, categories)
    ((categories.size) > index ) ? true : false    
  end

  def sanitize_title(title)
    sanitized_title =  title.gsub("/ ", "").gsub(" /","").gsub("/","")
  end
end
