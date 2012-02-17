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
          ContentSecurityPolicy.new(app, 'script-src' => "'self'")
        end.should raise_error(ContentSecurityPolicy::IncorrectDirectivesError, 'You have to set default-src directive.')
      end

      it 'should raise error if both policy-uri and other directive was set' do
        lambda do
          ContentSecurityPolicy.new(app, 'policy-uri' => 'policy.xml', 'script-src' => "'self'")
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
          ContentSecurityPolicy.new(app, 'default-src' => "'self'")
        end.should_not raise_error
      end
    end

    describe '#configure' do
      it 'should call block for directives hash' do
        ContentSecurityPolicy.should_receive(:configure).and_yield(Hash.new)
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
        csp['default-src'] = '*'
        csp['script-src']  = "'self'"
        csp['img-src']     = '*.google.com'
      end
    end

    describe '#call' do
      it 'should respond with X-Content-Security-Policy HTTP response header' do
        directives = "default-src *; script-src 'self'; img-src *.google.com"
        get('/').headers['X-Content-Security-Policy'].should == directives
      end

      it 'should respond with X-WebKit-CSP HTTP response header' do
        directives = "default-src *; script-src 'self'; img-src *.google.com"
        get('/').headers['X-WebKit-CSP'].should == directives
      end
    end
  end
end
