# HTTP Request/Response Cycle

<!-- TOC -->

- [Summary](#summary)
- [Browser](#browser)
- [DNS lookup](#dns-lookup)
- [Web server](#web-server)
- [App server](#app-server)
    - [How an app server communicates with Rails?](#how-an-app-server-communicates-with-rails)
    - [Rack](#rack)
    - [Rackup](#rackup)
        - [How to use?](#how-to-use)
        - [Middlewares](#middlewares)
- [App - Rails](#app---rails)
    - [Rails.application is a Rack app](#railsapplication-is-a-rack-app)
    - [How about middlewares?](#how-about-middlewares)
    - [How does a request get to a controller's action? - The Router](#how-does-a-request-get-to-a-controllers-action---the-router)
    - [How to make the Router point to whatever app you want?](#how-to-make-the-router-point-to-whatever-app-you-want)
- [Resources](#resources)

<!-- /TOC -->

## Summary

<div align="center">
  <img src="./images/request-response-lifecycle.svg" alt="Request/Response lifecycle"/>
</div>

## Browser

The user types in: `https://hamax97.github.io/home`:


1. Hostname resolution:

   - If the browser has in its cache the ip address for `hamax97.github.io`, it uses it;
   - Otherwise, it issues a [DNS lookup](#dns-lookup).

2. TODO: when and how does the TLS happen?

3. Once the browser has the ip address it creates a TCP connection with the [web server](#web-server).
   It then starts speaking the HTTP protocol. To test this locally, start your web application and run:

   ```bash
   telnet localhost 3000
   # Trying 127.0.0.1...
   # Connected to localhost.
   # Escape character is '^]'.
   > GET /articles HTTP/1.1
   > Host: localhost

   # you need two end-of-lines above, but not this line.
   ```

   Or you can try to a real web page:

   ```bash
   printf "%s\r\n" \
     "GET /questions HTTP/1.1" \
     "Host: stackoverflow.com" \
     "" |
   nc -v stackoverflow.com 443
   ```

   Using the headers `Connection: Keep-Alive` and `Keep-Alive: timeout=5, max=1000` you can manage
   the lifecyle of the connection.

## DNS lookup

TODO: From my notes, create page: How DNS works?

The ip address is returned to the browser if found: `51.52.53.91`.

## Web server

- Useful to handle hundreds of thousands of connections at a time.
- Useful to serve static files.
- Useful to work as reverse proxy.
- Useful to handle SSL handshakes.
- NGINX for example.

## App server

Useful for:

- Communication with the web framework, for example, Rails.
- To hand over complex requests to the web framework, the ones that are not just serving static content.
- To handle thousands of connections.
- To handle SSL handshakes.

Examples: PUMA / Guinicorn / ...

### How an app server communicates with Rails?

There are multiple ways in which this could be done in Ruby. Read until the end to see what is the
standard option servers use, **Rack**.

- Rails could register a block with the web server:

  ```ruby
  server.on_request do |request, response|
    request.path     # => "/hello"
    request.headers  # => { host: ... }

    response.status = 200
    response.body = "Hello World"
  end
  ```

- The server could call a method on Rails:

  ```ruby
  MyApp.handle_request(
    http_method, # => "GET"
    http_path,   # => "/hello",
    http_headers # => #<Headers @host=...>
  )

  # => #<Response @status=200 @body="Hello World">
  ```

- The server could place the request information in environment variables:

  ```ruby
  ENV["REQUEST_INFO"]
  ENV["PATH_INFO"]
  ENV["HTTP_HOST"]

  puts "Status: 200 OK"
  puts
  puts "Hello World"
  ```

- **The standard option, Rack**: A unified API to present a way for web servers to communicate with
  Ruby web frameworks.

### Rack

Rack is a protocol. It states that a web application is an object (commonly called `app`) that:

- Responds to the `call` message.
- The `call` message receives the `env` hash.
  - This hash looks like:

    ```ruby
    env = {
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/hello",
      "HTTP_HOST" => "hamax97.github.io",
      # ...
    }
    ```

- The `call` message returns an array with three things in order (a tuple): `status`, `headers`, and `body`.
  Like this:

  ```ruby
  status, headers, body = app.call(env)

  status  # => 200
  headers # => { "Content-Type" => "text/plain" }
  body    # => ["Hello World"]
  ```

  For technical reasons the `body` is an `each`able object, not just a plain string.

  TODO: Find out why `body` needs to be an `each`able object. Perhaps for streaming responses?

### Rackup

Interface (wrapper) for running Rack applications. It provides:

- A way to add middlewares to your application.
- A wrapper around an application server, for example, PUMA or WEBrick.

#### How to use?

Install:

```ruby
gem install rackup
```

This is a very simple Rack app:

```ruby
# app.rb

class HelloWorld
  def call(env)
    if env["PATH_INFO"] == "/hello"
      [200, { "content-type" => "text/plain" }, ["Hello World"]]
    elsif env["PATH_INFO"] == "/"
      [301, { "location" => "/hello" }, []]
    else
      [404, { "content-type" => "text/plain" }, ["Not Found"]]
    end
  end
end
```

- Note there's no subclassing from Rack or something like that. Remember, Rack is just a
  protocol/specification.
- Also, note that it would be very hard to maintain this if statement in larger applications.

Create a `config.ru` file:

```ruby
# config.rb

require_relative "app"

run HelloWorld.new
```

Run:

```bash
rackup
```

- This command will read the `config.ru` file and start the server.

#### Middlewares

How about extracting the redirect functionality from the `HelloWorld` app so that it can be
reused?

```ruby
class Redirect
  def initialize(app, from:, to:)
    @app = app
    @from = from
    @to = to
  end

  def call(env)
    if env["PATH_INFO"] == @from
      [301, { "location" => @to }, []]
    else
      @app.call(env)
    end
  end
end

class HelloWorld
  def call(env)
    if env["PATH_INFO"] == "/hello"
      [200, { "content-type" => "text/plain" }, ["Hello World"]]
    else
      [404, { "content-type" => "text/plain" }, ["Not Found"]]
    end
  end
end
```

And the `config.ru`:

```ruby
require_relative "app"

run Redirect.new(
  HelloWorld.new,
  from: "/",
  to: "/hello"
)
```

- Now you can reuse the `Redirect` functionality. This is called a **middleware**.

The **middleware** is not a concept in the Rack specification itself, rather, it's a useful technique
that has been broadly adopted.

Note, though, that it would get really complicated to nest the `HelloWorld.new` inside more and more
functionalities. For this, Rackup provides `use` in its DSL:

```ruby
require_relative "app"

use Redirect, from: "/", to: "/hello"

run HelloWorld.new
```

Rack provides some useful middlewares.

## App - Rails

### `Rails.application` is a Rack app

Rails generated a `config.ru` file when you scaffolded your application. It looks like:

```ruby
# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
Rails.application.load_server
```

`Rails.application` must be an object that follows the Rack specification (a Rack app). Let's try using the
Rails' console:

Run:

```bash
bin/rails console
```

Then:

```ruby
> env = Rack::MockRequest.env_for("http://localhost:3000/articles")
> env
#  =>
# {"rack.version"=>[1, 3],
#  "rack.input"=>#<StringIO:0x00007f1d6e414a50>,
#  ...
#  "REQUEST_METHOD"=>"GET",
#  "SERVER_NAME"=>"localhost",
#  "SERVER_PORT"=>"3000",
#  "QUERY_STRING"=>"",
#  "PATH_INFO"=>"/articles",
#  ...}

> status, headers, body = Rails.application.call(env)
# Started GET "/articles" for  at 2023-06-16 12:34:00 -0500
# Processing by ArticlesController#index as HTML
#   Rendering layout layouts/application.html.erb
#   Rendering articles/index.html.erb within layouts/application
#   ...
# Completed 200 OK in 5ms (Views: 4.3ms | ActiveRecord: 0.2ms | Allocations: 2943)

> status
#  => 200

> headers
#  =>
# {"X-Frame-Options"=>"SAMEORIGIN",
#  "X-XSS-Protection"=>"0",
#  ...
#  "Set-Cookie"=>
#  "_learn_rails_session=...; path=/; HttpOnly; SameSite=Lax",
#  ...
#  "Server-Timing"=>
#   "start_processing.action_controller;dur=0.07, sql.active_record;dur=0.35, instantiation.active_record;dur=0.09, render_template.action_view;dur=1.88, render_layout.action_view;dur=3.85, process_action.action_controller;dur=4.90"}

> puts body.join("")
# <!DOCTYPE html>
# <html>
#   <head>
#     <title>LearnRails</title>
#     <meta name="viewport"
# ...
```

### How about middlewares?

In the `config.ru` file we don't see any `use` keyword. So, where are the middlewares?

Rails handles middlewares differently. To see the list of middlwares used run:

```bash
bin/rails middleware
# use ActionDispatch::HostAuthorization
# use Rack::Sendfile
# use ActionDispatch::Static
# use ActionDispatch::Executor
# use ActionDispatch::ServerTiming
# use ActiveSupport::Cache::Strategy::LocalCache::Middleware
# use Rack::Runtime
# use Rack::MethodOverride
# ...
```

If you want you can remove middlewares if you don't need them, or you can add your own.
Go to your `config/application.rb` file:

```ruby
# Disable cookies middleware.
config.middleware.delete ActionDispatch::Cookies
config.middleware.delete ActionDispatch::Session::CookieStore
config.middleware.delete ActionDispatch::Flash

# Add you own middleware.
config.middleware.use CaptchaEverywhere
```

### How does a request get to a controller's action? - The Router

The last output line of the command `bin/rails middleware` is something like `run LearnRails::Application.routes`:

```bash
bin/rails middleware
# use ...
# run LearnRails::Application.routes
```

`LearnRails::Application.routes` should be a Rack app:

```ruby
> env = Rack::MockRequest.env_for("http://localhost:3000/articles")

> status, headers, body = LearnRails::Application.routes.call(env)
# Processing by ArticlesController#index as HTML
#   ...
# Completed 200 OK in 94ms (Views: 69.9ms | ActiveRecord: 2.0ms | Allocations: 56523)
```

It is! It matches the url path against a set of rules in your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles" => "articles#index"
  get "/articles/new" => "articles#new"
  post "/articles" => "articles#create"
end
```

Each of these routes expands to: `ArticlesController.action(:index)` or `:new` or `:create` instead of
`:index`.

`ArticlesController.action` returns a lambda that accepts the `env` hash. Remember lambdas respond
to `.call`, therefore, this lambda returned is a Rack app.

Want to look at Rail's source code? Look at the
[`action` class method here](https://github.com/rails/rails/blob/main/actionpack/lib/action_controller/metal.rb#L289).

Therefore, this Rails app could be thought as the following Rack app:

```ruby
class LearnRails
  def call(env)
    verb = env["REQUEST_METHOD"]
    path = env["PATH_INFO"]

    if verb == "GET" && path == "/articles"
      ArticlesController.action(:index).call(env)
    elsif verb == "POST" && path == "/articles"
      ArticlesController.action(:create).call(env)
    elsif # ...
    else
      [404, {"content-type": "text-plain", ...}, ["Not Found"]]
    end
  end
end
```

For more details on how the Rails Router works, see
[RailsConf 2018: Re-graphing The Mental Model of The Rails Router](https://www.youtube.com/watch?v=lEC-QoZeBkM).

### How to make the Router point to whatever app you want?

- You can match your route to a Rack app instead of specifying the controller and action in a string:

  ```ruby
  Rails.application.routes.draw do
    get "/articles" => HelloWorld.new

    get "/other-thing" => ->(env) {
      [200, {"content-type": "text-plain"}, ["Hello World!"]]
    }

    # redirect(...) returns a Rack app!
    get "/" => redirect("/articles")
  end
  ```

- You can mount a Sinatra app in your Rails app:

  ```ruby
  Rails.application.routes.draw do
    # Sidekiq's web app was built with Sinatra.
    mount Sidekiq::Web, at: "/sidekiq"
  end
  ```

- You can use `ArticlesController.action(:your_action)` directly. This is NOT recommended, though.
  It skips performance optimizations and the auto loader:

  ```ruby
  Rails.application.routes.draw do
    get "/articles" => ArticlesController.action(:index)
    get "/articles/new" => ArticlesController.action(:new)
    post "/articles" => ArticlesController.action(:create)
  end
  ```

## Resources

- [RailsConf 2019 - Inside Rails: The lifecycle of a request](https://www.youtube.com/watch?v=eK_JVdWOssI)
- [RailsConf 2020 - Inside Rails: The lifecycle of a response](https://www.youtube.com/watch?v=edjzEYMnrQw)
- [RailsConf 2018: Re-graphing The Mental Model of The Rails Router](https://www.youtube.com/watch?v=lEC-QoZeBkM)
