require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Imp::Test::Rspec::RouteMatchers do
  module Imp::Test::Rspec::RouteMatchers

    describe RouteToMatcher do
      before :each do
        @route = Imp::Router::MatchedRoute.new(Find, :all)
      end

      it 'should not pass if the controllers do not match' do
        RouteToMatcher.new(FindAll, :all).matches?(@route).should be_false
      end

      it 'should not pass if the actions do not match' do
        RouteToMatcher.new(Find, :default).matches?(@route).should be_false
      end

      it 'should pass if the controllers and actions match' do
        RouteToMatcher.new(Find, :all).matches?(@route).should be_true
      end

      #

      it 'should work with snake cased commands' do
        RouteToMatcher.new('find', :all).matches?(@route).should be_true
      end

      it 'should work with camel cased commands' do
        RouteToMatcher.new('Find', :all).matches?(@route).should be_true
      end

      it 'should work with commands supplied as a class' do
        RouteToMatcher.new(Find, :all).matches?(@route).should be_true
      end

      it 'should work with symbol or string command name' do
        RouteToMatcher.new('find', :all).matches?(@route).should be_true
        RouteToMatcher.new(:find, :all).matches?(@route).should be_true
      end

      it 'should work with symbol or string action name' do
        RouteToMatcher.new('find', :all).matches?(@route).should be_true
        RouteToMatcher.new(:find, :all).matches?(@route).should be_true
      end

      #

      it 'should include the expected command and action names in the "should" failure message' do
        matcher = RouteToMatcher.new(FindAll, :all)
        matcher.matches?(@route)
        message = matcher.failure_message_for_should
        message.should include('expected route to FindAll#all')
      end

      it 'should include the actual command and action names in the "should" failure message' do
        matcher = RouteToMatcher.new(FindAll, :all)
        matcher.matches?(@route)
        message = matcher.failure_message_for_should
        message.should include('but was Find#all')
      end

      it 'should include the expected not-be-be command and action names in the "should not" failure message' do
        matcher = RouteToMatcher.new(FindAll, :all)
        matcher.matches?(@route)
        message = matcher.failure_message_for_should_not
        message.should include('expected not to be a route to FindAll#all')
      end

      #

      it 'should expose a route_to helper' do
        @route.should route_to(Find, :all)
      end
    end

  end
end
