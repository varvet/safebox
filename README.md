# Safebox

[![Build Status](https://travis-ci.org/elabs/safebox.svg?branch=master)](http://travis-ci.org/elabs/safebox)
[![Dependency Status](https://gemnasium.com/elabs/safebox.svg)](https://gemnasium.com/elabs/safebox)
[![Code Climate](https://codeclimate.com/github/elabs/safebox/badges/gpa.svg)](https://codeclimate.com/github/elabs/safebox)
[![Gem Version](https://badge.fury.io/rb/safebox.svg)](http://badge.fury.io/rb/safebox)
[![Inline docs](http://inch-ci.org/github/elabs/safebox.svg?branch=master&style=shields)](http://inch-ci.org/github/elabs/safebox)

*Psst, full documentation can be found at [rubydoc.info/gems/safebox](http://www.rubydoc.info/gems/safebox)*

Simple encrypted storage of application secrets using [libsodium](https://download.libsodium.org/doc/).

Safebox is sponsored by [Elabs][].

[![elabs logo][]][Elabs]

[Elabs]: http://www.elabs.se/
[elabs logo]: ./elabs-logo.png?raw=true

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'safebox'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install safebox

## Usage

### Using the CLI

TODO.

```
safebox -h
```

### Using the API

``` ruby
require "safebox"

password = "this is a super-secret password"
message = "Elvis lives!"

encrypted_message = Safebox.encrypt(password, message)
decrypted_message = Safebox.decrypt(password, encrypted_message)
```

### Using econfig

First, add safebox to your Gemfile:

``` ruby
gem "econfig", require: "econfig/rails"
gem "safebox", require: "safebox/econfig"
```

Safebox will automatically configure econfig for you.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/elabs/safebox. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](CODE_OF_CONDUCT.md) code of conduct.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
