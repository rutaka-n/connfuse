# Connfuse

[![Build Status](https://travis-ci.org/rutaka-n/connfuse.svg?branch=master)](https://travis-ci.org/rutaka-n/connfuse) [![Code Climate](https://codeclimate.com/github/rutaka-n/connfuse/badges/gpa.svg)](https://codeclimate.com/github/rutaka-n/connfuse) [![Test Coverage](https://codeclimate.com/github/rutaka-n/connfuse/badges/coverage.svg)](https://codeclimate.com/github/rutaka-n/connfuse/coverage) [![Issue Count](https://codeclimate.com/github/rutaka-n/connfuse/badges/issue_count.svg)](https://codeclimate.com/github/rutaka-n/connfuse)

Connfuse is a Ruby circuit breaker gem. It protects your application from failures of it's service dependencies. It wraps calls to external services and monitors for failures.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'connfuse'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install connfuse

## Usage

You can use Circuit class directly:
```ruby
  circuit = Connfuse::Circuit.new
  circuit.pass_thru do
    some_transport.data.get(params)
  end
```
Or you can include Connfuse module in your class and specify methods:
```ruby
class Foo
  include Connfuse

  def bar
    # do something
  end

  fuse_for :bar
end
```
Circuit will be initialized for your class automatically
or you can specify parameters:
```ruby
  circuit(limit: 5, timeout: 15, expected_errors: [SomeErrorClass])
```
 - limit - count of tries to execute method before circuit will be broken.
 - timeout - specify time to fast failing your methods.
 - expected_errors - array of error's classes which do not count how errors of circuit.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/connfuse. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

