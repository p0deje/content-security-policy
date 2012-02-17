require 'spec_helper'

describe ContentSecurityPolicy do

  context 'configuration' do
    let(:app) do
      [200, { 'Content-Type' => 'text/plain' }, %w(ok)]
    end

    describe '#initialize' do
      it 'should raise error if directives hash is not present' do
        lambda do
          ContentSecurityPolicy.new(app)
        end.should raise_error(ContentSecurityPolicy::NoDirectivesError, 'No directives were passed.')
      end

      it 'should raise error if default-src was not set' do
        lambda do
          options = { :directives => { 'script-src' => "'self'" }}
          ContentSecurityPolicy.new(app, options)
        end.should raise_error(ContentSecurityPolicy::IncorrectDirectivesError, 'You have to set default-src directive.')
      end

      it 'should raise error if both policy-uri and other directive was set' do
        lambda do
          options = { :directives => { 'policy-uri' => 'policy.xml', 'script-src' => "'self'" }}
          ContentSecurityPolicy.new(app, options)
        end.should raise_error(ContentSecurityPolicy::IncorrectDirectivesError, "You passed both policy-uri and other directives.")
      end

      it 'should allow setting directives with ContentSecurityPolicy.configure' do
        ContentSecurityPolicy.configure { |csp| csp['default-src'] = "'self'" }
        ContentSecurityPolicy.should_receive(:directives).and_return('default-src' => '*')

        lambda do
          ContentSecurityPolicy.new(app)
        end.should_not raise_error(ContentSecurityPolicy::NoDirectivesError, 'No directives were passed.')
      end

      it 'should allow passing hash of directives' do
        lambda do
          options = { :directives => { 'default-src' => "'self'" }}
          ContentSecurityPolicy.new(app, options)
        end.should_not raise_error
      end

      it 'should allow passing report_only attribute' do
        lambda do
          options = { :directives => { 'default-src' => "'self'" }, :report_only => true }
          ContentSecurityPolicy.new(app, options)
        end.should_not raise_error
      end
    end

    describe '#configure' do
      it 'should call block for self' do
        ContentSecurityPolicy.should_receive(:configure).and_yield(ContentSecurityPolicy)
        ContentSecurityPolicy.configure { |csp| csp['default-src'] = '*' }
      end

      it 'should save directives hash' do
        ContentSecurityPolicy.configure { |csp| csp['default-src'] = '*' }
        ContentSecurityPolicy.directives.should == { 'default-src' => '*' }
      end

      it 'should append directives' do
        ContentSecurityPolicy.configure { |csp| csp['default-src'] = '*' }
        ContentSecurityPolicy.configure { |csp| csp['script-src']  = '*' }
        ContentSecurityPolicy.directives.should == { 'default-src' => '*',
                                                     'script-src'  => '*' }
      end

      it 'should save report_only attribute' do
        ContentSecurityPolicy.configure { |csp| csp.report_only = true }
        ContentSecurityPolicy.report_only.should be_true
      end
    end
  end

  context 'middleware' do
    let(:app) do
      Rack::Builder.app do
        use ContentSecurityPolicy
        run lambda { |env| [200, {'Content-Type' => 'text/plain'}, %w(ok)] }
      end
    end

    before(:each) do
      ContentSecurityPolicy.configure do |csp|
        csp.report_only = false
        csp['default-src'] = '*'
        csp['script-src']  = "'self'"
        csp['img-src']     = '*.google.com'
      end
    end

    describe '#call' do
      it 'should respond with X-Content-Security-Policy HTTP response header' do
        directives = "default-src *; img-src *.google.com; script-src 'self'"

        header = get('/').headers['X-Content-Security-Policy']
        header.should_not be_nil
        header.should_not be_empty
        header.should == directives
      end

      it 'should respond with X-WebKit-CSP HTTP response header' do
        directives = "default-src *; img-src *.google.com; script-src 'self'"

        header = get('/').headers['X-WebKit-CSP']
        header.should_not be_nil
        header.should_not be_empty
        header.should == directives
      end

      it 'should respond with X-Content-Security-Policy-Report-Only HTTP response header' do
        ContentSecurityPolicy.configure { |csp| csp.report_only = true }
        directives = "default-src *; img-src *.google.com; script-src 'self'"

        header = get('/').headers['X-Content-Security-Policy-Report-Only']
        header.should_not be_nil
        header.should_not be_empty
        header.should == directives
      end

      it 'should respond with X-WebKit-CSP HTTP response header' do
        ContentSecurityPolicy.configure { |csp| csp.report_only = true }
        directives = "default-src *; img-src *.google.com; script-src 'self'"

        header = get('/').headers['X-WebKit-CSP-Report-Only']
        header.should_not be_nil
        header.should_not be_empty
        header.should == directives
      end
    end
  end
end
