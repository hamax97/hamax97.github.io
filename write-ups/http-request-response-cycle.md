# HTTP Request/Response Cycle

<!-- TOC -->

- [Browser](#browser)
- [DNS lookup](#dns-lookup)
- [Web server](#web-server)
- [App server](#app-server)
    - [How a web server communicates with Rails?](#how-a-web-server-communicates-with-rails)
    - [Rack](#rack)
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

There are multiple ways in which this could be done in Ruby. Read till the final to see what is the
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

## App

TODO: continue here ... 15:15 - https://www.youtube.com/watch?v=eK_JVdWOssI
## Resources

- [RailsConf 2019 - Inside Rails: The lifecycle of a request](https://www.youtube.com/watch?v=eK_JVdWOssI)
- [RailsConf 2020 - Inside Rails: The lifecycle of a response](https://www.youtube.com/watch?v=edjzEYMnrQw)
- [RailsConf 2018: Re-graphing The Mental Model of The Rails Router](https://www.youtube.com/watch?v=lEC-QoZeBkM)
