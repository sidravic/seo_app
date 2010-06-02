require 'fileutils'
require 'net/http'
class Category
  include DataMapper::Resource
  include CustomException

  property :id, Serial
  property :title, String
  property :parent_id, Integer
  property :slug, String
  property :created_at, DateTime
  
  has n, :category_keywords
  has n, :user_keywords
  # *******************************************************************************
  #This creates the necessary CREATE statements to create the tables in the database
  #It drops tables if alreadys exists and creates the database afresh
  #****************************************************************************
  # DataMapper.auto_migrate!
  
  ANSWERICA_CLASSIFIER = "http://184.73.234.206:8080/qc/classifyIt?search="
  CATEGORIES_FILE_LOCATION = '/home/siddharth/Desktop/categories1.1.txt'
   
 
  def to_param
     self.slug
  end

  # expects an array    
   
  def find_all_subcategories
    total_categories = categories = []
    sub_categories = Category.all(:parent_id => self.id)
    sub_categories.each do |category|                 
      categories = Category.all(:parent_id => category.id)
      total_categories += categories 
    end
    (sub_categories + total_categories)
  end


  # saves the file with the following steps
  # Checks if the folder config/csv exists, creates it if it doesn't
  # If all is set the initiates the copy process
  def self.save_file(file)
    file_name =  "category_keyword.csv"
    content_type = file.content_type
    raise CustomException::InvalidFileFormatException unless content_type == "text/csv"
    Dir.mkdir("#{RAILS_ROOT}/config/csv") unless File.exists?("#{RAILS_ROOT}/config/csv")
    destination_path = File.join("#{RAILS_ROOT}/config/csv")
    delete_file("#{RAILS_ROOT}/config/csv/category_keyword.csv")
    Category.copy_file(file, destination_path, file_name) ? true : false
  rescue CustomException::InvalidFileFormatException =>e
    RAILS_DEFAULT_LOGGER.warn "[ERROR] #{e.message} #{e.backtrace}"
    return [false, "InvalidFileFormat"] 
  rescue => e
    RAILS_DEFAULT_LOGGER.warn "[ERROR] #{e.message} #{e.backtrace}"
    return [false, "Something Went Wrong"] 
  end  


  def self.initiate_category_load
    Category.reset_class_variable_counts
    Category.delete_all_categories_and_keywords
    load_count = Category.load_categories  
    load_count > 0 ? load_count : nil 
  end

  def self.category_exists?(category_title)
    Category.first(:title => category_title) 
  end

  def self.categorize(search_params)
   category = call_answerica_for_category(search_params)
   answerica_recommended_category = category.split(";")[0]
   seo_category =  find_category_by_title(answerica_recommended_category)
   seo_category.add_user_keyword(search_params)    
  end

  def self.find_category_by_title(title)
    Category.first(:conditions=>["title like ?", "%#{title}%"])
  end

  def add_user_keyword(search_params)
    self.user_keywords << UserKeyword.new(:keyword => search_params.strip.downcase) unless user_keyword_exists?(search_params)
    self.save
  end

  def user_keyword_exists?(search_params)
   (self.user_keywords.all(:conditions => [" keyword = ? ", search_params.strip.downcase ])).empty? ? false : true
  end


  private

  # checks if its a Tempfile
  # Creates a file called categories.csv in the write mode.
  # Copies the contents of the Tempfile into the categories.csv file
  def self.copy_file(file, destination_path, filename)
    if file.instance_of? Tempfile
      File.new("#{destination_path}/#{filename}", 'w')
      RAILS_DEFAULT_LOGGER.debug " LOCAL PATH " +  file.local_path
      FileUtils.copy(file.local_path, "#{destination_path}/#{filename}")
    end
    return true
  rescue => e
    RAILS_DEFAULT_LOGGER.warn "[ERROR] Something went wrong. Your file could not be uploaded"
    return false
  end  

  def self.delete_file(filename)
    if File.exists?(filename)
      File.delete(filename)
    end
  end


  # static variables to enable loading of categories it could be instance variables too but in this case
  # this does not affect the way the system works

  @@category_id = 0  
  @@sub_category_id = 0 
  @@super_subcategory_id = 0
  @@id = 0

  def self.reset_class_variable_counts
    @@category_id = 0  
    @@sub_category_id = 0 
    @@super_subcategory_id = 0
    @@id = 0
  end

  #TODO the path needs to be changed to a default RAILS location
  def self.load_categories
    file = File.open(CATEGORIES_FILE_LOCATION)
    while(line = file.gets)     
      puts line
      new_entry = line
      self.new_category(new_entry) if (line.index("**").nil? && line.index("|").nil?)
      self.new_subcategory(new_entry) if line.index("|")
      self.new_super_subcategory(new_entry) if line.index("**")
    end
    @@id
  end

  def self.new_category(new_entry)
    puts "NEW CATEGORY => #{new_entry}"
    title = new_entry.strip
    category = Category.create(:title=>title, :parent_id => nil, :slug => self.create_slug(title))   
    if category
      @@category_id = category.id
    end
    @@id += 1
  end

  def self.new_subcategory(new_entry)
    puts "NEW SUBCATEGORY => #{new_entry}"
    title =  new_entry.split("|")
    sub_category = Category.create(:title=>title[1].strip, :parent_id => @@category_id, :slug => self.create_slug(title[1]))
    if sub_category
      @@sub_category_id = sub_category.id
    end
    @@id +=1   
  end

  def self.new_super_subcategory(new_entry)
    puts "NEW SUPERSUBCATEGORY => #{new_entry}"
    title =  new_entry.split("**")
    super_sub_category =  Category.create(:title =>title[1].strip, :parent_id =>@@sub_category_id,
                                          :slug =>self.create_slug(title[1]))
    if super_sub_category
      @@super_sub_category_id = super_sub_category.id   # not really needed but just in case
    end
    @@id +=1
  end

  def self.delete_all_categories_and_keywords
    CategoryKeyword.auto_migrate!
    Category.auto_migrate!
  end

  def self.create_slug(title)
    RAILS_DEFAULT_LOGGER.debug " title " + title.inspect
    title = title.strip.gsub("/","").gsub("/ ", "").gsub(" /","")
    slug = title.split.join("-")
  end


  def self.call_answerica_for_category(search_params)
   escaped_search_params = URI.escape(search_params) 
   uri = URI.parse( ANSWERICA_CLASSIFIER + "#{escaped_search_params}")
   http =  Net::HTTP.new(uri.host, uri.port)
   response = http.get(uri.path + "?search=#{escaped_search_params}")
   response.body
  end

end
