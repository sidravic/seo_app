class UserKeywordsController < ApplicationController
  def index
    @user_keywords = UserKeyword.all
  end

end
