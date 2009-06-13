require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

# Command names ==============================================================

describe '' do
  before :all do
    Imp.load_application(File.expand_path(File.join(File.dirname(__FILE__), 'fixture')))
  end

  describe 'Default command names' do
    it 'should be automatically set when the class is created' do
      command = Imp::Test::Fixtures::Commands::Verysilly
      command.command_name.should == 'verysilly'
    end

    it 'should convert CamelCase to string with spaces' do
      command = Imp::Test::Fixtures::Commands::UsesCamelCase
      command.command_name.should == 'uses camel case'
    end

    it 'should not use the superclasses default name' do
      command = Imp::Test::Fixtures::Commands::HasSuperClass
      command.command_name.should == 'has super class'
    end

    it 'should use a default when inheriting from a superclass with a custom name' do
      command = Imp::Test::Fixtures::Commands::FromCustom
      command.command_name.should == 'from custom'
    end
  end

  describe 'Setting a custom command name' do
    it 'should set the name attribute on the Command' do
      Imp::Test::Fixtures::Commands::CustomName.command_name.should == 'hello'
    end

    it 'should remove old router mappings' do
      Imp::Router.match(['custom name']).should be_nil
    end
  end
end
