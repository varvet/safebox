module Safebox
  class File
    def initialize(path, password)
      @path = path
      @password = password
    end

    def keys
      data.keys
    end

    def has_key?(key)
      data.has_key?(key)
    end

    def get(key)
      data[key]
    end

    def set(key, value)
      data[key] = value
      write
    end

    def update(attributes)
      data.merge!(attributes)
      write
    end

    def delete(*args)
      args.each { |key| data.delete(key) }
      write if ::File.exists?(@path)
    end

    def data
      @data ||= if ::File.exists?(@path)
        ciphertext = ::File.read(@path, encoding: Encoding::BINARY)
        decrypted = Safebox.decrypt(@password, ciphertext)
        JSON.parse(decrypted)
      else
        {}
      end
    end

  private

    def write
      ciphertext = Safebox.encrypt(@password, JSON.generate(data))
      ::File.write(@path, ciphertext, encoding: Encoding::BINARY)
    end
  end
end
