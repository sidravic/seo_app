require 'digest'

class Admin 
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :email, String, :format => :email_address
  property :encrypted_password, String, :length=>100
  property :created_at, DateTime
  property :last_access_at, DateTime
  property :salt, String   

  attr_accessor :password, :password_confirmation

  def encrypt_password(password, salt)
    Digest::SHA1.hexdigest(password + salt)
  end

  def generate_salt
    Time.now.utc
  end

  def authenticate_admin
    admin = Admin.first(:email => self.email)
    authenticated_admin = nil
    if admin
      encrypted_password = self.encrypt_password(self.password, admin.salt)
      authenticated_admin = Admin.first(:email => admin.email, :encrypted_password => encrypted_password)
    end
    authenticated_admin
  end

  def update_last_access_at
    RAILS_DEFAULT_LOGGER.debug "self => " + self.inspect
    self.update(:last_access_at => DateTime.now)
  end
 
end
