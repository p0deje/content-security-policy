require 'content-security-policy/middleware'
require 'content-security-policy/errors'
require 'content-security-policy/version'

class ContentSecurityPolicy
  class << self

    # @attr_reader [Hash] directives hash
    attr_reader :directives

    #
    # Configures Content Security Policy directives.
    #
    # Note that default-src directive should always be set.
    #
    # @example
    #   ContentSecurityPolicy.configure do |csp|
    #     csp['default-src'] = "'self'"
    #     csp['script-src']  = '*.example.com'
    #   end
    #   use ContentSecurityPolicy
    #
    # @yield [Hash] directives Calls block for directives
    #
    def configure(&blk)
      @directives ||= {}
      blk.call(@directives)
    end

  end # << self
end # ContentSecurityPolicy

