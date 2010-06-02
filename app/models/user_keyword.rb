class UserKeyword
  include DataMapper::Resource

  property :id, Serial
  property :keyword, String

  belongs_to :category    

end

