require "safebox"
require "json"
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
      file.data.each do |key, value|
        $stdout.puts "#{key}=#{value}"
      end
    end

    def get(key)
      if file.has_key?(key)
        $stdout.print file.get(key)
        $stdout.puts if $stdout.tty?
      else
        Kernel.abort "no such key: #{key}"
      end
    end

    def set(*args)
      updates = args.map { |arg| arg.split("=", 2) }.to_h
      file.update(updates)
    end

    def delete(*args)
      file.delete(*args)
    end

    def to_s
      @parser.to_s
    end

    def file
      @file ||= Safebox::File.new(path, password)
    end

    private

    def path
      @options[:file] or "./safe.box"
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
