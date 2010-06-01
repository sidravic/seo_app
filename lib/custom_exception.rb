module CustomException
  class FileNotFoundException < StandardError; end 
  class InvalidFileFormatException < StandardError; end 
end
