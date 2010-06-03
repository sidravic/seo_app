class UserKeywordsController < ApplicationController
  def index
    @categories = Category.all
  end

end
