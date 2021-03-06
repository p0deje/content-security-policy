class ContentSecurityPolicy

  # @attr_reader [Boolean] report_only Use in report only mode
  attr_reader :report_only

  # @attr_reader [Hash] directives Directives hash
  attr_reader :directives

  #
  # Initializes Content Security Policy middleware.
  #
  # @param [Hash] options Options hash
  # @option options [Boolean] :report_only Set to true if use in report-only mode
  # @option options [Hash] :directives Directives hash
  #
  # @example
  #   use ContentSecurityPolicy, :directives => { 'default-src' => "'self'" }
  #   use ContentSecurityPolicy, :directives => { 'default-src' => "'self'" }, :report_only => true
  #
  def initialize(app, options = {})
    @app = app
    @report_only = options[:report_only] || ContentSecurityPolicy.report_only
    @directives  = options[:directives]  || ContentSecurityPolicy.directives

    @directives or raise NoDirectivesError, 'No directives were passed.'

    # make sure directives with policy-uri don't contain any other directives
    if @directives['policy-uri'] && @directives.keys.length > 1
      raise IncorrectDirectivesError, 'You passed both policy-uri and other directives.'
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
    directives = @directives.sort.map { |dir| "#{dir[0]} #{dir[1]}" }.join('; ')

    # prepare response headers names
    if @report_only
      resp_headers = %w(
        Content-Security-Policy-Report-Only
        X-Content-Security-Policy-Report-Only
        X-WebKit-CSP-Report-Only
      )
    else
      resp_headers = %w(
        Content-Security-Policy
        X-Content-Security-Policy
        X-WebKit-CSP
      )
    end

    # append response header
    resp_headers.each do |resp_header|
      headers[resp_header] = directives
    end

    [status, headers, response]
  end

end # ContentSecurityPolicy
