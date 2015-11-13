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
end
