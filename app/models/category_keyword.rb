require "fastercsv"

class CategoryKeyword
  include DataMapper::Resource
  include CustomException

  property :id, Serial
  property :keyword, String

  belongs_to :category



  def self.initiate_category_keyword_upload
    CategoryKeyword.delete_category_keyword_data
    status, error  = CategoryKeyword.upload_category_keyword
    if status
      Category.delete_file("#{RAILS_ROOT}/config/csv/category_keyword.csv")
    else
      return [false, error]
    end
    true
  end

  private

  def self.upload_category_keyword
    raise CustomException::FileNotFoundException unless File.exists?("#{RAILS_ROOT}/config/csv/category_keyword.csv")
    category_keyword_arrays = FasterCSV.read("#{RAILS_ROOT}/config/csv/category_keyword.csv")
    category_keywords = category_keyword_arrays.transpose                                            # turns columns into rows. Ruby is awesome
    category_keywords.each do | category |
      if category_obj = Category.category_exists?(category[0])
        category.delete(nil)                                           # removes all the unwanted nil values that get added in the csv document
        add_keywords(category_obj, category) 
      end
    end
    [true, nil]
  rescue CustomException::FileNotFoundException
    RAILS_DEFAULT_LOGGER.warn "[ERROR] File Not Found in #{RAILS_ROOT}/config/csv/categories_keywords.csv. Upload the category keyword csv file"
    puts "[ERROR] File Not Found in #{RAILS_ROOT}/config/csv/categories_keywords.csv"
    [false,  "File Not Found in #{RAILS_ROOT}/config/csv/categories_keywords.csv" ]
  rescue=> e
    RAILS_DEFAULT_LOGGER.warn "[ERROR] #{e.message} #{e.backtrace} "
    puts  "[ERROR] #{e.message} #{e.backtrace} "
    [false, "#{e.message} "] 
  end

  def self.add_keywords(category_obj, category)
    cat_keywords = category.uniq                                          # remove duplicates
    cat_keywords.each do |keyword|
      category_obj.category_keywords << CategoryKeyword.new(:keyword => keyword)    
    end
    category_obj.save ? true : false
  end

  def self.delete_category_keyword_data
    CategoryKeyword.auto_migrate!
  end
end
