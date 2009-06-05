require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

Spec::Runner.configure do |config|
  config.after :each do
    Imp::Router.reset!
  end
end
