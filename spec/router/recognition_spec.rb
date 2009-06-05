require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

#
# TODO: Replace the stuff below with a helper.
#
# Imp::Router.match(...).should be_route
# Imp::Router.match(...).should be_route_to(:command => ...)
# Imp::Router.match(...).should_not be_route
# Imp::Router.match(...).should_not be_route_to(:command => ...)
#

# Shared behaviour.
describe 'route recognition with extra arguments', :shared => true do
  it 'should remove route segments from the returned args' do
    Imp::Router.match(@args).args.should be_empty
  end

  describe 'with extra arguments' do
    before :each do
      @args_with_non_opts = @args +
        %w( first second third -a --b penultimate final )

      @non_opt_match = Imp::Router.match(@args_with_non_opts)
    end

    it 'should return leading non-opts intact' do
      @non_opt_match.args[0..2].should == %w( first second third )
    end

    it 'should return switches intact' do
      @non_opt_match.args[-4..-3].should == %w( -a --b )
    end

    it 'should return trailing non-opts intact' do
      @non_opt_match.args[-2..-1].should == %w( penultimate final )
    end
  end
end

# ----------------------------------------------------------------------------

describe 'Route recognition' do

  #

  describe 'when route {name:"find" command:"Find"} is defined,' do

    before do
      Imp::Router.register('find', Find)
      @args = %w( find all )
    end

    # Matches.

    it 'should route "find" to Find#default' do
      route = Imp::Router.match(%w( find ))
      route.command.should == Find
      route.action.should == :default
    end

    it 'should route "find all" to Find#all' do
      route = Imp::Router.match(@args)
      route.command.should == Find
      route.action.should == :all
    end

    it 'should route "find all files" to Find#all' do
      route = Imp::Router.match(%w( find all files ))
      route.command.should == Find
      route.action.should == :all
    end

    it 'should route "find All" to Find#default' do
      route = Imp::Router.match(%w( find All ))
      route.command.should == Find
      route.action.should == :default
    end

    it 'should route "find -a all to Find#default"' do
      route = Imp::Router.match(%w( find -a all ))
      route.command.should == Find
      route.action.should == :default
    end

    # Non-matches.

    it 'should not route "nothing"' do
      Imp::Router.match(%w( nothing )).should be_nil
    end

    it 'should not route "Find all"' do
      Imp::Router.match(%w( Find all )).should be_nil
    end

    # Util.

    it_should_behave_like 'route recognition with extra arguments'

  end

  #

  describe 'when route {name:"find all" command:"Find" action:"everything"} is defined,' do

    before do
      Imp::Router.register('find all', Find, :everything)
      @args = %w( find all )
    end

    # Matches.

    it 'should route "find all" to Find#everything' do
      route = Imp::Router.match(%w( find all ))
      route.command.should == Find
      route.action.should == :everything
    end

    it 'should route "find all files" to Find#everything' do
      route = Imp::Router.match(%w( find all files ))
      route.command.should == Find
      route.action.should == :everything
    end

    # Non-matches.

    it 'should not route "find"' do
      Imp::Router.match(%w( find )).should be_nil
    end

    it 'should not route "Find all"' do
      Imp::Router.match(%w( Find all )).should be_nil
    end

    it 'should not route "find All"' do
      Imp::Router.match(%w( find All )).should be_nil
    end

    it 'should not route "nothing"' do
      Imp::Router.match(%w( nothing )).should be_nil
    end

    it 'should not route "find -a all"' do
      Imp::Router.match(%w( find -a all )).should be_nil
    end

    # Util.

    it_should_behave_like 'route recognition with extra arguments'

  end

  #

  describe 'when route {name:"find all" command:"FindAll"} is defined,' do

    before do
      Imp::Router.register('find all', FindAll)
      # Requires an extra 'files' argument on the end to be gobbled up as the
      # action name...
      @args = %w( find all files )
    end

    # Matches.

    it 'should route "find all" to FindAll#default' do
      route = Imp::Router.match(%w( find all ))
      route.command.should == FindAll
      route.action.should == :default
    end

    it 'should route "find all files" to Find#files' do
      route = Imp::Router.match(%w( find all files ))
      route.command.should == FindAll
      route.action.should == :files
    end

    # Non-matches.

    it 'should not route "find"' do
      Imp::Router.match(%w( find )).should be_nil
    end

    it 'should not route "Find all"' do
      Imp::Router.match(%w( Find all )).should be_nil
    end

    it 'should not route "find All"' do
      Imp::Router.match(%w( find All )).should be_nil
    end

    it 'should not route "nothing"' do
      Imp::Router.match(%w( nothing )).should be_nil
    end

    it 'should not route "find -a all"' do
      Imp::Router.match(%w( find -a all )).should be_nil
    end

    # Util.

    it_should_behave_like 'route recognition with extra arguments'

  end

  #

  describe 'when route {name:"find-all" command:"Find" action:"everything"} is defined,' do

    before do
      Imp::Router.register('find-all', Find, :everything)
      @args = %w( find-all )
    end

    # Matches.

    it 'should route "find-all" to Find#everything' do
      route = Imp::Router.match(%w( find-all ))
      route.command.should == Find
      route.action.should == :everything
    end

    it 'should route "find-all files" to Find#everything' do
      route = Imp::Router.match(%w( find-all files ))
      route.command.should == Find
      route.action.should == :everything
    end

    # Non-matches.

    it 'should not route "find"' do
      Imp::Router.match(%w( find )).should be_nil
    end

    it 'should not route "find all"' do
      Imp::Router.match(%w( find all )).should be_nil
    end

    it 'should not route "Find-all"' do
      Imp::Router.match(%w( Find-all )).should be_nil
    end

    it 'should not route "find-All"' do
      Imp::Router.match(%w( find-All )).should be_nil
    end

    it 'should not route "nothing"' do
      Imp::Router.match(%w( nothing )).should be_nil
    end

    it 'should not route "find -a all"' do
      Imp::Router.match(%w( find - all )).should be_nil
    end

    # Util.

    it_should_behave_like 'route recognition with extra arguments'

  end

end
