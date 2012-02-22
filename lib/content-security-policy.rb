require 'content-security-policy/middleware'
require 'content-security-policy/errors'
require 'content-security-policy/version'

class ContentSecurityPolicy
  class << self

    # @attr [Boolean] report_only Use in report only mode
    attr_accessor :report_only

    # @attr_reader [Hash] directives Directives hash
    attr_reader :directives

    #
    # Configures Content Security Policy directives.
    #
    # Note that default-src directive should always be set.
    #
    # @example
    #   ContentSecurityPolicy.configure do |csp|
    #     csp.report_only = true
    #     csp['default-src'] = "'self'"
    #     csp['script-src']  = '*.example.com'
    #   end
    #   use ContentSecurityPolicy
    #
    # @yield [ContentSecurityPolicy]
    #
    def configure(&blk)
      @directives ||= {}
      blk.call(self)
    end

    #
    # Sets directive.
    #
    # @param [String] name Directive name
    # @param [String] value Directive value
    #
    def []=(name, value)
      @directives[name] = value
    end

  end # << self
end # ContentSecurityPolicy
