require "safebox"
require "yaml"
require "io/console"
require "optparse"

module Safebox
  class CLI
    def initialize(defaults = {})
      @options = defaults
      @commands = {
        list:   [nil, "Lists all keys and their values"],
        get:    ["KEY", "Prints the given key to STDOUT"],
        set:    ["KEY=VALUE [KEY=VALUE...]", "Sets the value of the given keys"],
        delete: ["KEY [KEY...]", "Delete the given keys"],
      }

      indent = " " * 4
      @parser = OptionParser.new do |opts|
        opts.banner = "Usage: safebox [options] [command]"
        opts.version = Safebox::VERSION

        opts.separator ""
        opts.separator "Commands:"

        width = 33
        @commands.each do |command, (arguments, description)|
          command = "#{command} #{arguments}"
          opts.separator indent + command.ljust(width) + description
        end

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

      if command and @commands.include?(command.to_sym)
        public_send(command, *args)
        true
      end
    end

    def list
      hash.each do |key, value|
        $stdout.puts "#{key}=#{value}"
      end
    end

    def get(key)
      $stdout.print hash.fetch(key) { Kernel.abort "no such key: #{key}" }
      $stdout.puts if $stdout.tty?
    end

    def set(*args)
      args.each do |arg|
        key, value = arg.split("=", 2)
        hash[key] = value
      end

      safebox.write(hash)
    end

    def delete(*args)
      did_change = false
      args.each do |key|
        did_change = true if hash.has_key?(key)
        hash.delete(key)
      end
      safebox.write(hash) if did_change
    end

    def to_s
      @parser.to_s
    end

    def file
      @options[:file] or "./safe.box"
    end

    private

    def safebox
      @safebox ||= Safebox::File.new(file)
    end

    def hash
      @hash ||= safebox.read(password) do |hash, old_version|
        $stderr.puts "Your safebox was upgraded from v#{old_version} to v#{Safebox::VERSION}."
        safebox.write(hash)
      end
    end

    def password
      @options[:password] ||= begin
        $stderr.print "Password: "
        password = $stdin.noecho(&:gets).chomp
        $stderr.puts ""
        password
      end
    end
  end
end
