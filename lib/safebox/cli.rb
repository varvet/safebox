require "safebox"
require "json"
require "io/console"

module Safebox
  class CLI
    def initialize(options)
      @options = options
    end

    def file
      @options[:file] or "./safe.box"
    end

    def run(command, args)
      if command and respond_to?(command)
        public_send(command, *args)
        true
      end
    end

    def list
      read_contents.each do |key, value|
        $stdout.puts "#{key}=#{value}"
      end
    end

    def set(*args)
      updates = args.map { |arg| arg.split("=", 2) }.to_h
      new_contents = read_contents.merge(updates)
      write_contents(new_contents)
    end

    def delete(*args)
      contents = read_contents

      new_contents = contents.slice(contents.keys - args)

      write_contents(new_contents)
    end

    private

    def password
      @password ||= begin
        $stderr.print "Password: "
        password = $stdin.noecho(&:gets).chomp
        $stderr.puts ""
        password
      end
    end

    def write_contents(contents)
      ciphertext = Safebox.encrypt(password, JSON.generate(contents))
      File.write(file, ciphertext, encoding: Encoding::BINARY)
    end

    def read_contents
      if File.exists?(file)
        ciphertext = File.read(file, encoding: Encoding::BINARY)
        decrypted = Safebox.decrypt(password, ciphertext)
        JSON.parse(decrypted)
      else
        {}
      end
    end
  end
end
