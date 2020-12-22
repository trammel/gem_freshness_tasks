# GemFreshnessTasks

This code performs a "gem freshness" check, to ensure that the number of gems in your application code that are outdated isn't too large.

## Custodians

Email: [Jonathon Padfield](mailto:jonathon.padfield@gmail.com)

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'gem_freshness_tasks'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install gem_freshness_tasks
```

Require the rake tasks within your application.

```ruby
require 'gem_freshness_tasks'
```

Then run `rake -T` to see the available tasks.

### Running Tests locally

* Running the rubocop and tests

```
bundle exec rake
```

The tests are limited to basically unit tests. Bootstrapping an application with full end-to-end tests is a desired future feature.

## Credits

[REA-Group](https://www.rea-group.com/careers/), where I first saw this pattern

## Contributing

Fork, write test, write code, run tests, repeat, rinse, raise PR.

## TODO

* Full end-to-end tests
