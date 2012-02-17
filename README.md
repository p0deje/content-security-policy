## Description

Implementation of Content Security Policy as Rack middleware.
More information about Content Security Policy - http://http://www.w3.org/TR/CSP/.

## Installation

Install as usually:

    gem install content-security-policy

## Usage

Add Content Security Policy to your Rack configuration:

    # config.ru
    require 'content-security-policy'
    use ContentSecurityPolicy
    run MyApp

## Copyright

Copyright (c) 2012 Alex Rodionov. See LICENSE for details.
