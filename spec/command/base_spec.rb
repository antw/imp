require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

# Command names ==============================================================

# TODO: OHMIGOSH!
# TEMPORARY FIXTURES - These absolutely need to be removed as soon as the
#                      command class, and the router, are sorted.

class Verysilly < Imp::Command
end

class UsesCamelCase < Imp::Command
end

class HasSuperClass < UsesCamelCase
end

class CustomName < Imp::Command
  command 'hello'
end

class FromCustom < CustomName
end

describe 'Default command names' do
  it 'should be automatically set when the class is created' do
    Verysilly.command_name.should == 'verysilly'
  end

  it 'should convert CamelCase to string with spaces' do
    UsesCamelCase.command_name.should == 'uses camel case'
  end

  it 'should not use the superclasses default name' do
    HasSuperClass.command_name.should == 'has super class'
  end

  it 'should use a default when inheriting from a superclass with a custom name' do
    FromCustom.command_name.should == 'from custom'
  end

  it 'should do something with Name::Spaces'
end

describe 'Setting a custom command name' do
  it 'should set the name attribute on the Command' do
    CustomName.command_name.should == 'hello'
  end

  it 'should remove old router mappings'
  it 'should add a new router mapping'
  it 'should raise an error if the command name has already been defined'
end
