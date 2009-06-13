require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe 'The default Imp directory structure' do
  before :all do
    @dir = File.expand_path(File.join(File.dirname(__FILE__), 'default_structure'))
    Imp.load_application(@dir)
  end

  it 'should set the root path' do
    Imp.root.should == @dir
  end

  it 'should load commands' do
    lambda { Imp::Test::Fixtures::DefaultStructure::Default }.should_not raise_error
  end

  it 'should mount commands in the router' do
    Imp::Router.match(['default']).should \
      route_to(Imp::Test::Fixtures::DefaultStructure::Default, :default)
  end
end

describe 'Custom Imp directory structures' do
  before :all do
    @dir = File.expand_path(File.join(File.dirname(__FILE__), 'custom_structure'))
    Imp.load_application(File.join(@dir, 'config', 'imp.rb'))
  end

  it 'should set the root path' do
    Imp.root.should == @dir
  end

  it 'should load commands' do
    lambda { Imp::Test::Fixtures::CustomStructure::Custom }.should_not raise_error
  end

  it 'should mount commands in the router' do
    Imp::Router.match(['custom']).should \
      route_to(Imp::Test::Fixtures::CustomStructure::Custom, :default)
  end
end

describe 'Imp.load_application' do
  it 'should raise an error if the given path does not exist' do
    lambda {
      Imp.load_application(File.expand_path(File.join(File.dirname(__FILE__), 'not_real')))
    }.should raise_error(Imp::ApplicationLoadError)
  end

  it 'should raise an error if given a directory without an imp.rb file' do
    lambda {
      Imp.load_application(File.expand_path(File.join(File.dirname(__FILE__), 'custom_structure')))
    }.should raise_error(Imp::ApplicationLoadError)
  end
end
