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
- [Resources](#resources)

<!-- /TOC -->

## Background

- [HTTP Request/Response Lifecycle](./http-request-response-lifecycle.md)

## The response array

All Rack-compliant web frameworks must respond to a request with a **response array**: `[status, headers, body].

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

TODO: continue here at 09:30 -> https://www.youtube.com/watch?v=edjzEYMnrQw

## Resources

- [HTTP status codes](https://httpstatuses.com)
- [HTTP Request/Response Lifecycle](./http-request-response-lifecycle.md)
- [RailsConf 2019 - Inside Rails: The lifecycle of a request](https://www.youtube.com/watch?v=eK_JVdWOssI)
- [RailsConf 2020 - Inside Rails: The lifecycle of a response](https://www.youtube.com/watch?v=edjzEYMnrQw)
- [RailsConf 2018: Re-graphing The Mental Model of The Rails Router](https://www.youtube.com/watch?v=lEC-QoZeBkM)