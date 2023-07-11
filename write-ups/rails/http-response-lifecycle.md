# HTTP Response Lifecycle

<!-- TOC -->

- [Background](#background)
- [The response array](#the-response-array)
- [The status code](#the-status-code)
    - [Examples](#examples)
        - [No Content - 204](#no-content---204)
        - [Found - 302](#found---302)
        - [Moved Permanently - 301](#moved-permanently---301)
- [The headers](#the-headers)
    - [Examples](#examples)
        - [Location](#location)
        - [Content-Type](#content-type)
        - [Content-Length](#content-length)
        - [Set-Cookie](#set-cookie)
        - [Cache-Control](#cache-control)
    - [Cache-Control: Default behavior in Rails](#cache-control-default-behavior-in-rails)
        - [For dynamic content](#for-dynamic-content)
        - [For static content - Cache busting](#for-static-content---cache-busting)
- [Resources](#resources)

<!-- /TOC -->

## Background

- [HTTP Request/Response Lifecycle](./http-request-response-lifecycle.md)

## The response array

All Rack-compliant web frameworks must respond to a request with a **response array**: `[status, headers, body]`.

- `status` is the status code.
- `headers` is a hash with the headers.
- `body` is an `each`able object. Usually an array with a single element, a string.

Rails is a Rack-compliant web framework.

## The status code

Three-digit number that indicates if the request was successful or not:

- 1xx: informational.
- 2xx: success.
- 3xx: redirection.
- 4xx: client error, error originated in the client.
- 5xx: server error, error originated in the server.

Status codes help clients, usually browsers, make sense of the response.

Status codes tell the **Google Crawler** what to do:
- Pages responding with 5xx will be revisited later.
- Pages responding with 2xx will be indexed.

Try to be as precise as possible with your status codes.

For more information go to: **httpstatuses.com**.

### Examples

#### No Content - 204

```ruby
class ArticlesController < ApplicationController
  def check_presence
    @articles = Article.all
    if not @articles.empty?
      head :no_content # 204 -> no response body.
    else
      render :index, status: :not_found # 404
    end
  end
end
```

- `head` is a shorthand in Rails for responding only with: status, headers, and an empty body.
- The browser then will not expect a response body to render.

#### Found - 302

```ruby
class ArticlesController < ApplicationController
  before_action { redirect_to new_article_url if current_user.some_condition? }
  # ...
end
```

- The response looks like:

  ```
  HTTP/1.1 302 Found
  Location: http://localhost:3000/articles/new
  Content-Type: text/html
  ...
  ```

- This status tells the browser to look for the resource where the `Location` header points to.

#### Moved Permanently - 301

```ruby
class ArticlesController < ApplicationController
  def find_resource
    redirect_to new_article_url, status: :moved_permanently
  end
  # ...
end
```

- The response looks like:

  ```
  HTTP/1.1 301 Moved Permanently
  Location: http://localhost:3000/articles/new
  Content-Type: text/html
  ...
  ```

- This status tells the browser to always look for this resource where the `Location` header points to.
  The browser can now issue a request to `Location` instead of issuing the extra request with 301 as status code.

- Alternatively you can use `redirect` in your routes file. `redirect` returns 301 as well.:

  ```ruby
  Rails.application.routes.draw do
    get "/find-resource", to: redirect("/new-permanent-location")
  end
  ```

## The headers

Although status codes convey important information, often more information is required.

Headers are additional information about a response/request. For example:

- How long to cache the response.
- Metadata to use in a JavaScript client app.

Second element in the response array.

For headers not managed by any of your middlewares you can use:

```ruby
response.headers['HEADER NAME'] = 'some value'
```

### Examples

#### Location

Tells the client where to find the requested content:

```
Location: https://some.other.resource/path
```

#### Content-Type

Tells the client the content type of the response:

```
Content-Type: text/plain
Content-Type: application/json
Content-Type: multipart/form-data; boundary...
```

#### Content-Length

Tells how many bytes are in the response body.

You could send a `HEAD` request to the server and it could respond with `200 OK` and with a
`Content-Length` header, but without the body. This way you could build a load percentage bar.

```
Content-Length: 12
```

Added automatically by the Rack content middleware.

#### Set-Cookie

Contains a semi-colon separated key-value string representing the cookies shared between the server
and the browser.

Examples:

- There are cookies to track a user's request accross a session.
- There are cookies to help the server remember a user's action or preferences.
- Tacking cookies help tracking what websites you visitted. This helps advertisement companies to show
  what could be of interest to you.

These cookies are managed in Rails with the gem called `cookiejar`.

#### Cache-Control

You can instruct your browser to cache entire HTTP responses so that next time they are shown
more quickly.

You can enable caching in Rails using:

```bash
bin/rails dev:cache
```

**Cache forever**

If you want your response to be cached for ever use `http_cache_forever`:

```ruby
class ArticlesController < ApplicationController
  def show
    http_cache_forever { render :show }
  end
  # ...
end
```

Which will result in the header:

```
Cache-Control: max-age=3155695200, private
```

- `max-age` is a value in seconds, in this case it is the same as 1 century.
- `private` indicates that this resource is preferred to be cached by the user's browser and not
  by any proxies in the path to the browser.

> Question
>
> The browser is still making the request to Rails, but Rails responds with `304 Not Modified`.
> Who has the cache, the browser or Rails? Why is this request sent over and over again?

For an answer to this read below,
[Rails' default caching behavior for dynamic content](#for-dynamic-content).

**Cache forever publicly**

```ruby
class ArticlesController < ApplicationController
  def show
    http_cache_forever(public: true) { render :show }
  end
  # ...
end
```

**Cache for specific amounts of time**

```ruby
class ArticlesController < ApplicationController
  def show
    @articles = Article.all
    :expires_in 1.second, public: false
  end
  # ...
end
```

**Never-ever cache the resource**

```ruby
class ArticlesController < ApplicationController
  def show
    response.headers["cache-control"] = "no-store"
    @articles = Article.all
  end
  # ...
end
```

- `no-store` is different from `no-cache`, `no-cache` indicates that the response must be revalidated
  always before using the value in the cache. Why is this useful? Because you could get a `304 Not Modified`.
  For an explanation on how revalitaion works read below
  [Rails' default caching behavior](#cache-control-default-behavior-in-rails).

### Cache-Control: Default behavior in Rails

#### For dynamic content

For dynamic content (e.g. HTML) Rails by default sends the `Cache-Control` header with the following directives:

```
Cache-Control: max-age=0, private, must-revalidate
```

The `must-revalidate` directive indicates to the client that it must **revalidate** (with a
**conditional request**) the cached response if it becomes **stale**, that is, if the response has
been cached for longer than `max-age`.

If you look carefully, `max-age` is set to zero, which indicates that the response will always become
**stale** immediately.

How does this revalidation happen?

  - The browser sends the first request. It receives a 200 OK, together with the body, and in the headers
    there are the following important headers:

    - `ETag` header (entity tag), which is a string for differentiating between multiple representations
      of the same resource. The `Rack::ETag` middleware is what appends this header.
    - `Cache-Control`, as explained above.

  - The browser caches the resource and its `ETag` with it.
  - The next time the browser requests the same resource, that is it **revalidates**, it will make
    a **conditional request**, that is, it will include the headers:

   - `If-None-Match`, set to a list of `ETag`s, in this case to the `ETag` of the resource requested. Rails will
     compute again the body of the response, and if the `ETag` matches it will return `304 Not Modified`.

     > Tip
     >
     > To avoid computing an entire body just to compare if the ETag matches, you can use the Rails method
     > `stale?`, which checks if a model has changed by looking at its updated_at date.

   - `If-Modified-Since`, set to a date, if the resource hasn't been modified since the specified date,
     the server will return `304 Not Modified`.

  - If this process is not followed in the client (there's no support), every time you request the same resource,
    you'll get a 200 OK together with the the body, no matter if the server sent the `Cache-Control` header.
    It is therefore responsibility of the client to handle this appropiately.

  - To avoid making these **conditional requests** you can use the directive `immutable` which can also be included
    in the `Cache-Control` header. Read below
    [Rails' default caching behavior for static content](#for-static-content---cache-busting).

How to use the `stale?` method?

```ruby
class ArticlesController < ApplicationController
  def show
    http_cache_forever(public: true) { render :show }
    if stale?(@articles)
      # some expensive calls with @articles
      # ...
      render :show
    else
      puts "Do nothing"
      render :show # this will generate a DoubleRender error!!
    end
  end
  # ...
end
```

- `stale?` under the hood generates a string from the combination of the model name, id, and updated at, then
  runs that string through the `ETag` digest algorithm.

#### For static content - Cache busting

For static content (css, js, images, ...) Rails uses the **cache busting pattern**, meaning that:

- It adds the header:

  ```
  Cache-Control: public, max-age=31536000, immutable
  ```

- It appends a hash of the contents of the file to the end of the file name.

The `immutable` directive indicates that the response will not be updated while it's **fresh**.

Whenever the client makes a request for an HTML page, the HTML content includes the path to the
CSS stylesheets, images, and JavaScript files. Each path has a hash of the content of the file
appended to it. If one of these files change, the hash will change and the HTML content will point
to a different file, therefore, making the client request this new file instead of using the one in
the cache.

Also, the `immutable` directive tells the client to avoid making **conditional requests** to Rails to
validate if the content has changed, unless the cached content gets **stale**, that is, the time that
the resource has been in the cache exceeds the value in `max-age`.

Using these two things, (1) the hash of the file appended to its URL, and (2) the `immutable` directive,
is the **cache busting pattern**.

For more information on the `Cache-Control` header, visit the official documentation
[here](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control).

- For Dynamic content: TODO: continue here at 20:10 -> https://www.youtube.com/watch?v=edjzEYMnrQw

## Resources

- [HTTP status codes](https://httpstatuses.com)
- [HTTP Request/Response Lifecycle](./http-request-response-lifecycle.md)
- [RailsConf 2019 - Inside Rails: The lifecycle of a request](https://www.youtube.com/watch?v=eK_JVdWOssI)
- [RailsConf 2020 - Inside Rails: The lifecycle of a response](https://www.youtube.com/watch?v=edjzEYMnrQw)
- [RailsConf 2018: Re-graphing The Mental Model of The Rails Router](https://www.youtube.com/watch?v=lEC-QoZeBkM)