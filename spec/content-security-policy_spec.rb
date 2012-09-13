require 'spec_helper'

describe ContentSecurityPolicy do
  context 'configuration' do
    let(:app) do
      [200, { 'Content-Type' => 'text/plain' }, %w(ok)]
    end

    describe '#initialize' do
      it 'should raise error if directives hash is not present' do
        lambda {
          ContentSecurityPolicy.new(app)
        }.should raise_error(ContentSecurityPolicy::NoDirectivesError, 'No directives were passed.')
      end

      it 'should raise error if default-src was not set' do
        lambda {
          options = { :directives => { 'script-src' => "'self'" }}
          ContentSecurityPolicy.new(app, options)
        }.should raise_error(ContentSecurityPolicy::IncorrectDirectivesError, 'You have to set default-src directive.')
      end

      it 'should raise error if both policy-uri and other directive was set' do
        lambda {
          options = { :directives => { 'policy-uri' => 'policy.xml', 'script-src' => "'self'" }}
          ContentSecurityPolicy.new(app, options)
        }.should raise_error(ContentSecurityPolicy::IncorrectDirectivesError, "You passed both policy-uri and other directives.")
      end

      it 'should allow setting directives with ContentSecurityPolicy.configure' do
        ContentSecurityPolicy.configure { |csp| csp['default-src'] = "'self'" }
        ContentSecurityPolicy.should_receive(:directives).and_return('default-src' => '*')

        lambda {
          ContentSecurityPolicy.new(app)
        }.should_not raise_error(ContentSecurityPolicy::NoDirectivesError, 'No directives were passed.')
      end

      it 'should allow passing hash of directives' do
        lambda {
          options = { :directives => { 'default-src' => "'self'" }}
          ContentSecurityPolicy.new(app, options)
        }.should_not raise_error
      end

      it 'should allow passing report_only attribute' do
        lambda {
          options = { :directives => { 'default-src' => "'self'" }, :report_only => true }
          ContentSecurityPolicy.new(app, options)
        }.should_not raise_error
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
        ContentSecurityPolicy.directives.should == { 'default-src' => '*', 'script-src'  => '*' }
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
      %w(Content-Security-Policy X-Content-Security-Policy X-WebKit-CSP).each do |header|
        it "should respond with #{header} HTTP response header" do
          get('/').headers[header].should == "default-src *; img-src *.google.com; script-src 'self'"
        end
      end

      %w(Content-Security-Policy-Report-Only X-Content-Security-Policy-Report-Only X-WebKit-CSP-Report-Only).each do |header|
        it "should respond with #{header}  HTTP response header" do
          ContentSecurityPolicy.report_only = true
          get('/').headers[header].should == "default-src *; img-src *.google.com; script-src 'self'"
        end
      end
    end
  end
end
