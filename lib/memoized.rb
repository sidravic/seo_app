class Memoized
  attr_accessor :memory, :obj ,:method, :memoized_obj

  def initialize(obj, method)
    @memory = {}
    @object = obj
    @method = method
  end

  def self.memoize(obj, method)
    @memoized_object = Memoized.new(obj, method) 
  end

  def memoized
    if @memory.has_key?(@object.to_s)
      @memory[@object.to_s]
    else
      RAILS_DEFAULT_LOGGER.debug "object => #{@object} mthod=> #{@method}"
      @memory = @object.send(@method)
    end
  end
end
