## Content Security Policy

[![Build Status](https://secure.travis-ci.org/p0deje/content-security-policy.png)](http://travis-ci.org/p0deje/content-security-policy)

Implementation of Content Security Policy as Rack middleware.

More information about Content Security Policy - http://www.w3.org/TR/CSP/.

## Installation

Install as usually `gem install content-security-policy`

## Usage

Add Content Security Policy to your Rack configuration.

```ruby
# config.ru
require 'content-security-policy'

ContentSecurityPolicy.configure do |csp|
  csp['default-src'] = "'self'"
  csp['script-src']  = '*.example.com'
end

use ContentSecurityPolicy
run MyApp
```

or you can pass directives during initialization

```ruby
# config.ru
require 'content-security-policy'

use ContentSecurityPolicy, 'policy-uri' => 'policy.xml'
run MyApp
```

## Copyright

Copyright (c) 2012 Alexey Rodionov. See LICENSE for details.
