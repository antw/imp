require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

module DispatchSpec
  class Simple < Imp::Command
    def go
    end

    private

    def nothanks
    end
  end

  class WithArgs < Imp::Command
    arg :verbose

    def go
    end
  end

  class WithRequiredArgs < Imp::Command
    arg :path do
      required true
    end

    def go
    end
  end

  # --------------------------------------------------------------------------

  describe 'Dispatching an action' do
    it 'should not raise any errors' do
      lambda { Simple.new([])._dispatch(:go) }.should_not raise_error
    end

    it 'should raise an error when provided unknown arguments' do
      lambda { Simple.new(['-a'])._dispatch(:go) }.should raise_error(Imp::InvalidSwitch)
    end

    it 'should raise an error if the action does not exist' do
      lambda { Simple.new([])._dispatch(:invalid) }.should raise_error(Imp::ActionNotFound,
        "Action 'invalid' was not found in DispatchSpec::Simple")
    end

    it 'should raise an error if the action is private' do
      lambda { Simple.new([])._dispatch(:nothanks) }.should raise_error(Imp::ActionNotFound,
        "Action 'nothanks' was not found in DispatchSpec::Simple")
    end

    describe 'when optional arguments are defined' do
      it 'should not raise an error if an argument is not given' do
        command = WithArgs.new([])
        lambda { command._dispatch(:go) }.should_not raise_error

        command.arguments[:verbose].should_not be_true
      end

      it 'should parse given arguments' do
        command = WithArgs.new(['--verbose'])
        command._dispatch(:go)

        command.arguments[:verbose].should be_true
      end
    end

    describe 'when required arguments are defined' do
      it 'should raise an error if an argument is not given' do
        command = WithRequiredArgs.new([])
        lambda { command._dispatch(:go) }.should raise_error(Imp::MissingRequiredOption)
      end

      it 'should parse given arguments' do
        command = WithRequiredArgs.new(%w(--path yes))
        command._dispatch(:go)

        command.arguments[:path].should == 'yes'
      end
    end


  end

end
