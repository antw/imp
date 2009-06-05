require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

# TODO: Most of these specs test private functionality; they ought to be
#       rewritten to use route recognition, once it is implemented.

describe Imp::Router do
  describe '.register' do
    it 'should add the specified route' do
      Imp::Router.register('hello', Class)
      Imp::Router.routes.should have_key('hello')
    end

    it 'should default to no action' do
      Imp::Router.register('hello', Class)
      Imp::Router.routes['hello'][:action].should be_nil
    end

    it 'should permit specifying a custom action' do
      Imp::Router.register('hello', Class, :world)
      Imp::Router.routes['hello'][:action].should == :world
    end
  end

  describe '.remove' do
    it 'should remove a registered route' do
      Imp::Router.register('hello', Class)
      Imp::Router.remove('hello')
      Imp::Router.routes.should_not have_key('hello')
    end

    it 'should do nothing if the route is not present' do
      lambda { Imp::Router.remove('hello') }.should_not raise_error
    end
  end

  describe '.reset!' do
    it 'should remove all registered routes' do
      Imp::Router.register('hello', Class)
      Imp::Router.reset!
      Imp::Router.routes.should be_empty
    end

    it 'should do nothing if there are no registered routes' do
      lambda { Imp::Router.reset! }.should_not raise_error
      Imp::Router.routes.should be_empty
    end
  end
end
