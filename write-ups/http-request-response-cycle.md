# HTTP Request/Response Cycle

<!-- TOC -->

- [Browser](#browser)
- [DNS lookup](#dns-lookup)
- [Web server](#web-server)
- [App server](#app-server)
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

- How this communicates with Rails?

TODO: continue here ... 11:00 - https://www.youtube.com/watch?v=eK_JVdWOssI

## App

## Resources

- [RailsConf 2019 - Inside Rails: The lifecycle of a request](https://www.youtube.com/watch?v=eK_JVdWOssI)
- [RailsConf 2020 - Inside Rails: The lifecycle of a response](https://www.youtube.com/watch?v=edjzEYMnrQw)
- [RailsConf 2018: Re-graphing The Mental Model of The Rails Router](https://www.youtube.com/watch?v=lEC-QoZeBkM)
