# HTTP Request/Response Cycle

<!-- TOC -->

- [Browser](#browser)
- [DNS lookup](#dns-lookup)
- [Web server](#web-server)
- [App server](#app-server)
    - [How a web server communicates with Rails?](#how-a-web-server-communicates-with-rails)
    - [Rack](#rack)
    - [Rackup](#rackup)
        - [How to use?](#how-to-use)
        - [Middlewares](#middlewares)
- [App](#app)
- [Resources](#resources)

<!-- /TOC -->

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

### How a web server communicates with Rails?

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
functionalities. Rackup provides `use` in its DSL.

TODO: continue here ... 21:40 - https://www.youtube.com/watch?v=eK_JVdWOssI

## App

## Resources

- [RailsConf 2019 - Inside Rails: The lifecycle of a request](https://www.youtube.com/watch?v=eK_JVdWOssI)
- [RailsConf 2020 - Inside Rails: The lifecycle of a response](https://www.youtube.com/watch?v=edjzEYMnrQw)
- [RailsConf 2018: Re-graphing The Mental Model of The Rails Router](https://www.youtube.com/watch?v=lEC-QoZeBkM)
