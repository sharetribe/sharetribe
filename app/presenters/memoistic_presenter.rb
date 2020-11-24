class MemoisticPresenter
  extend Memoist

  class << self
    def memoize_all_reader_methods
      method_list = instance_methods - superclass.instance_methods
      # exclude attr accessors and methods with arguments
      to_memoize = method_list.reject do |name|
        name.to_s.index('=') || name.to_s.index('!') || method_list.index("#{name}=".to_sym) || instance_method(name).arity != 0
      end
      @memoized_reader_methods = to_memoize
      memoize(*to_memoize)
    end

    attr_reader :memoized_reader_methods
  end

end
