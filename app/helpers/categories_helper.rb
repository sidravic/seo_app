module CategoriesHelper

  # checks if the @categories array size is greater than the index of the current category obj passed
  # used for display in the Categories#index method

  def index_within_category_array?(index, categories)
   ((categories.size - 1) > index ) ? true : false    
  end
end
