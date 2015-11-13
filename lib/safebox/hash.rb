require "forwardable"

module Safebox
  class Hash
    Undefined = BasicObject.new

    include Enumerable
    extend Forwardable

    def initialize(password, data: {})
      @password = password
      @data = data
    end

    # @return [Hash] encrypted underlying data.
    attr_reader :data

    def_delegators :@data, :clear, :has_key?, :empty?, :keys, :length, :delete
    def_delegators :@data, :hash, :==

    def fetch(key, default = Undefined)
      default_value = ! default.equal?(Undefined)

      if default_value && block_given?
        raise ArgumentError, "give default value or default block, not both"
      elsif has_key?(key)
        decrypt(@data[key])
      elsif default_value
        default
      elsif block_given?
        yield key
      else
        raise KeyError, "key not found: #{key.inspect}"
      end
    end

    def [](key)
      fetch(key, nil)
    end

    def []=(key, value)
      @data[key] = encrypt(value)
    end

    def each
      unless block_given?
        enum_for(__method__)
      else
        keys.each { |key| yield key, fetch(key) }
      end
    end

    def hash
      [@data, @password].hash
    end

    def ==(other)
      other.is_a?(Safebox::Hash) && other.password == password && other.data == data
    end

    protected

    attr_reader :password

    def decrypt(data)
      Safebox.decrypt(@password, data)
    end

    def encrypt(data)
      Safebox.encrypt(@password, data)
    end
  end
end
