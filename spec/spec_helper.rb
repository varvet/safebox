require "bundler/setup"
require "safebox"
require "pry"

module Common
  def password
    "test1234"
  end
end

RSpec.configure do |config|
  config.include(Common)

  config.around do |example|
    case example.metadata[:tempfile]
    when :directory
      Dir.mktmpdir do |directory|
        Dir.chdir(directory) { example.run }
      end
    when false
      example.run
    else
      Tempfile.open(["safe", ".box"]) do |io|
        @tempfile = io.path
        FileUtils.rm(@tempfile)
        example.run
      end
    end
  end
end
