# Rack::Cachely

This is a piece of Rack Middleware for talking with the page caching service, [Cachely](http://www.cachelyapp.com). It supports any Rails/Rack application.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-cachely'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-cachely

## Usage

Cachely is currently available only as a Heroku Add-on.

### Rails 3.x

Step one is to set up your appropriate environment, such as `production.rb` to include the `Rack::Cachely` middleware.

```ruby
config.middleware.delete "Rack::Cache"
config.middleware.use Rack::Cachely
config.action_controller.perform_caching = true
```

Step two is to tell `Rack::Cachely` which pages you would like to cache, and for how long. `Rack::Cachely` is smart enough to know that only `GET` requests in the `200` range are valid for caching.

```ruby
before_filter do
  # Set pages to 'public' to allow them to be cached.
  # set the max-age so Cachely knows how long to keep
  # the pages for.
  headers['Cache-Control'] = 'public; max-age=86400'
end
```

### Detailed Configuration

```ruby
config.middleware.use Rack::Cachely,
  # Print debug information out to the log (default is false):
  verbose: false,
  # Each Cachely account has a custom URL endpoint.
  # The URL can be found in your Heroku config or through
  # your Cachely dashboard. By default it looks for an
  # ENV variable named CACHELY_URL:
  cachely_url: ENV["CACHELY_URL"],
  # How long are you willing to wait for requests to the Cachely
  # service to respond? Default is 1 second.
  timeout: 1.0
```

### Helpful Query Parameters

`Rack::Cachely` has a few helpful query string parameters you can add to do different things:

**no-cachely=true**: This will bypass Cachely and show you the page directly from your application. Great for debugging and testing pages.

**refresh-cachely=true**: This will delete the page from Cachely and re-cache it. Great when you've made changes and want to update the cache, but don't feel like doing it on the command line or through the dashboard.

### Expiring Pages Programmatically

When your system gets updated it would be nice to be able to programmatically expire pages that are associated with certain objects. Cachely let's you expire pages in your cache using Regular Expressions, to help make your life that much easier.

```Ruby
# Destroy all "user" pages, eg. "/users/1", "/users/2", etc...
Rack::Cachely::Store.delete("users/\d+")
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributors

* Mark Bates
* Sam Beam
* Tim Raymond