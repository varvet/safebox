require "forwardable"

module Safebox
  class Hash
    Undefined = BasicObject.new

    include Enumerable
    extend Forwardable

    # @param [String] password
    # @option [Hash] encrypted_hash (optional)
    def initialize(password, encrypted_hash: {})
      @password = password
      @encrypted_hash = encrypted_hash
    end

    attr_reader :encrypted_hash

    # @return [Hash] a copy of the decrypted hash.
    def to_h
      reduce({}) { |hash, (key, value)| hash.update(key => value) }
    end

    def_delegators :@encrypted_hash, :clear, :has_key?, :empty?, :keys, :length, :delete
    def_delegators :@encrypted_hash, :hash, :==

    # Behaves just as Hash#fetch, but values retrieved are decrypted.
    #
    # @param key
    # @return decrypted value
    def fetch(key, default = Undefined)
      default_value = ! default.equal?(Undefined)

      if default_value && block_given?
        raise ArgumentError, "give default value or default block, not both"
      elsif has_key?(key)
        decrypt(@encrypted_hash[key])
      elsif default_value
        default
      elsif block_given?
        yield key
      else
        raise KeyError, "key not found: #{key.inspect}"
      end
    end

    # @param key
    # @return decrypted value
    def [](key)
      fetch(key, nil)
    end

    # Encrypts and stores a value on the given key.
    #
    # @param key
    # @param value
    def []=(key, value)
      @encrypted_hash[key] = encrypt(value)
    end

    # Updates in place with another hash as source, same as Hash#update.
    #
    # @yield [key, old_value, new_value] yields if block is given and there is a conflict, the return value is used as the new value.
    # @return [Safebox::Hash] self
    def update(other_hash)
      other_hash.each do |key, value|
        value = yield key, self[key], value if block_given? && has_key?(key)
        self[key] = value
      end
      self
    end

    # Iterate through the entire store
    #
    # @yield [key, value] yield each key and its decrypted value.
    def each
      unless block_given?
        enum_for(__method__)
      else
        keys.each { |key| yield key, fetch(key) }
      end
    end

    # @return [Integer] return the hash of the Hash.
    def hash
      [@encrypted_hash, @password].hash
    end

    # @return [Boolean] true if this hash is the same as another hash.
    def ==(other)
      other.is_a?(Safebox::Hash) && other.password == password && other.to_h == to_h
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
