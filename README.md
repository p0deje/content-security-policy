## Content Security Policy

[![Build Status](https://secure.travis-ci.org/p0deje/content-security-policy.png)](http://travis-ci.org/p0deje/content-security-policy)

Implementation of Content Security Policy as Rack middleware.

More information about Content Security Policy - http://www.w3.org/TR/CSP/.

## Installation

Install as usually `gem install content-security-policy`

## Usage

Add Content Security Policy to your Rack configuration `config.ru`.

```ruby
require 'content-security-policy'

ContentSecurityPolicy.configure do |csp|
  csp['default-src'] = "'self'"
  csp['script-src']  = '*.example.com'
end

use ContentSecurityPolicy
run MyApplication
```

You can also pass directives during initialization.

```ruby
require 'content-security-policy'

use ContentSecurityPolicy, :directives => { 'policy-uri' => 'policy.xml' }
run MyApplication
```

You can also use report-only mode.

```ruby
require 'content-security-policy'

ContentSecurityPolicy.configure do |csp|
  csp.report_only = true
  csp['default-src'] = "'self'"
  csp['script-src']  = '*.example.com'
end

use ContentSecurityPolicy
run MyApplication
```

```ruby
require 'content-security-policy'

use ContentSecurityPolicy, :directives => { 'policy-uri' => 'policy.xml' }, :report_only => true
run MyApplication
```

## Status

Content Security Policy is now implemented with `Content-Security-Policy` (official name), `X-Content-Security-Policy` (Firefox and IE) and `X-WebKit-CSP` (Chrome and Safari) headers.

## Copyright

Copyright (c) 2012 Alexey Rodionov. See LICENSE for details.
