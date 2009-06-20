require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

module ArgumentSpec
  class HasSimpleArgument < Imp::Command
    arg :long
  end

  class HasAnotherArgument < HasSimpleArgument
    arg :verbose
  end

  class CustomisedArgument < Imp::Command
    arg :verbose do
      short '-q'
    end
  end
end

describe 'Defining an argument on a comment' do
  it 'should add the option to the argument list' do
    ArgumentSpec::HasSimpleArgument._arguments.should have(1).element
    ArgumentSpec::HasSimpleArgument._arguments[0].should \
      be_kind_of(Imp::Options::Option)
  end

  it 'should inherit arguments from superclasses' do
    ArgumentSpec::HasAnotherArgument._arguments.should have(2).elements
  end

  it 'should support customising arguments with a block' do
    ArgumentSpec::CustomisedArgument._arguments.first.short.should == '-q'
  end
end
