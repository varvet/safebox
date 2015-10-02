require "safebox"
require "json"
require "io/console"
require "optparse"

module Safebox
  class CLI
    def initialize(defaults = {})
      @options = defaults

      indent = " " * 4
      @parser = OptionParser.new do |opts|
        opts.banner = "Usage: safebox [options] [command]"
        opts.version = Safebox::VERSION

        opts.separator ""
        opts.separator "Commands:"

        width = 33
        opts.separator indent + "list".ljust(width) + "Lists all keys and their values"
        opts.separator indent + "get KEY".ljust(width) + "Gets the given key"
        opts.separator indent + "set KEY=VALUE [KEY=VALUE...]".ljust(width) + "Set value of given keys"
        opts.separator indent + "delete KEY".ljust(width) + "Delete the given key"

        opts.separator ""
        opts.separator "Common options:"
        opts.separator indent + "-h, --help"
        opts.separator indent + "-v, --version"
        opts.on("-f", "--file [SAFEBOX]", "Safebox file (safe.box)") do |file|
          @options[:file] = file
        end
      end
    end

    def run(*argv)
      command, *args = @parser.parse!(argv)

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

    def to_s
      @parser.to_s
    end

    def file
      @options[:file] or "./safe.box"
    end

    private

    def password
      @options[:password] ||= begin
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
