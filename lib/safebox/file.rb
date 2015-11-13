module Safebox
  class File
    def initialize(path)
      @path = path
    end

    attr_reader :path

    def write(hash)
      encoded = YAML.dump(hash.encrypted_hash)
      ::File.write(path, encoded, encoding: Encoding::BINARY)
    end

    # @yield [version] yield the file version if it is not current.
    # @return [Safebox::Hash] read a hash, no matter the underlying file version.
    def read(password)
      if ::File.exist?(path)
        contents = ::File.read(path, encoding: Encoding::BINARY)

        [Safebox::VERSION, "0.1.0"].each do |version|
          hash = begin
            public_send(version, password, contents)
          rescue NoMethodError
            raise
          rescue => error
            $stderr.puts "Decryption failed for v#{version}: #{error}" if $DEBUG
            next
          end

          yield hash, version if version != Safebox::VERSION
          return hash
        end
      else
        Safebox::Hash.new(password)
      end
    end

    # v0.1.0 had safe.box files as encrypted JSON.
    define_method("0.1.0") do |password, data|
      require "json"
      decrypted = Safebox.decrypt(password, data)
      json = JSON.parse(decrypted)
      hash = Safebox::Hash.new(password)
      json.each { |key, value| hash[key] = value }
      hash
    end

    # v0.2.0 had safe.box files as regular YAML with encrypted values.
    define_method("0.2.0") do |password, data|
      encrypted_hash = YAML.load(data)
      Safebox::Hash.new(password, encrypted_hash: encrypted_hash)
    end
  end
end
