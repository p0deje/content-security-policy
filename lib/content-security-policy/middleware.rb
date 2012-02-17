class ContentSecurityPolicy

  # @attr_reader [Hash] directives hash
  attr_reader :directives

  #
  # Initializes Content Security Policy middleware.
  #
  # @param [Hash] directives
  #
  # You can pass directives hash directly on middleware usage.
  # @example
  #   use ContentSecurityPolicy, 'default-src' => "'self'"
  #
  def initialize(app, directives = nil)
    @app = app
    @directives = directives || ContentSecurityPolicy.directives

    @directives or raise NoDirectivesError, 'No directives were passed.'

    # make sure directives with policy-uri don't contain any other directives
    if @directives['policy-uri'] && @directives.keys.length > 1
      raise IncorrectDirectivesError, 'You passed both policy-uri and other directives.'
    # make sure default-src is present
    elsif !@directives['policy-uri'] && !@directives['default-src']
      raise IncorrectDirectivesError, 'You have to set default-src directive.'
    end
  end

  #
  # @api private
  #
  def call(env)
    dup._call(env)
  end

  #
  # @api private
  #
  def _call(env)
    status, headers, response = @app.call(env)

    # flatten directives
    directives = @directives.map { |k, v| "#{k} #{v}" }.join('; ')
    # append response headers
    headers['X-Content-Security-Policy'] = directives
    headers['X-WebKit-CSP']              = directives

    [status, headers, response]
  end

end # ContentSecurityPolicy
