require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

##
# Although completely rewritten, many of these specs, like the OptionParser
# itself, area based on those for Thor's option parser. Credit goes to Yehuda
# Katz.
#
describe Imp::Options::OptionParser do
  ##
  # Adds the given option to the parser for the duration of the example and
  # uses the block (if present) to configure the option.
  #
  # Alternatively, you may specify multiple options, but any given
  # configuration block will be ignored.
  #
  def opt(*names, &blk)
    @_options ||= []

    if names.length == 1
      @_options << Imp::Options::Option.define(names.first, &blk)
    else
      @_options.push(*names.map do |name|
        Imp::Options::Option.define(name)
      end)
    end
  end

  ##
  # Parses the given +args+ with the parser and returns the results.
  #
  def parse(*args)
    Imp::Options::OptionParser.new(@_options || []).parse(args)
  end

  ##
  # Reset the parser after each example.
  #
  after :each do
    @_options = nil
  end

  # --------------------------------------------------------------------------

  describe 'switch variants' do
    it 'should accept long --switch switches' do
      opt :foo
      parse('--foo')[:foo].should be_true
    end

    it 'should accept --switch=<empty string> assignments' do
      opt :foo
      parse('--foo=')[:foo].should == ''
    end

    it 'should accept --switch=<value> assignments' do
      opt :foo
      parse('--foo=bar')[:foo].should == 'bar'
    end

    it 'should accept --switch=<value with space> assignments' do
      opt :foo
      parse('--foo=bar baz')[:foo].should == 'bar baz'
    end

    it 'should accept --switch <value> assignments' do
      opt :foo
      parse('--foo', 'bar')[:foo].should == 'bar'
    end

    it 'should accept -nXY assignments' do
      opt(:foo) { short '-n' }
      parse('-n12')[:foo].should == '12'
    end

    it 'should accept conjoined short switches' do
      opt :foo, :bar, :qux
      opts = parse('-fbq')

      opts[:foo].should be_true
      opts[:bar].should be_true
      opts[:qux].should be_true
    end
  end

  describe 'naming' do
    it 'should map automatically define short switches to the long name' do
      opt :foo
      parse('-f')[:foo].should be_true
    end

    it 'should not automatically define short switches which have already been defined'

    it 'should map custom defined short switches to the long name' do
      opt(:foo) { short '-b' }
      parse('-b')[:foo].should be_true

      # -f should not be auto-defined.
      lambda { parse('-f')[:foo] }.should raise_error(Imp::InvalidSwitch)
    end

    it 'should accept "no-opt" variant for booleans, setting false for value' do
      opt(:foo) { cast TrueClass }
      parse('--no-foo')[:foo].should be_false
    end

    it 'should not accept "no-opt" variants for non-booleans' do
      opt :foo
      lambda { parse('--no-foo')[:foo] }.should raise_error(Imp::InvalidSwitch)
    end

    it 'should prefer explicitly defined "no-opt" options over inverting "opt"' do
      opt(:bar) { long '--no-foo'}
      parse("--no-foo")[:bar].should be_true
    end
  end

  describe 'parse results' do
    before :each do
      opt :foo
      @opts = parse('--foo', '12')
    end

    it 'should make accessing available via a symbol' do
      @opts[:foo].should == '12'
    end

    it 'should make accessing available via a string' do
      @opts['foo'].should == '12'
    end

    it 'should be immutable' do
      klass = RUBY_VERSION < '1.9' ? TypeError : RuntimeError

      lambda { @opts[:new] = :baz }.should raise_error(klass, /frozen/)
      lambda { @opts.leading_non_opts = :baz }.should raise_error(klass, /frozen/)
      lambda { @opts.trailing_non_opts = :baz }.should raise_error(klass, /frozen/)
      lambda { @opts.leading_non_opts << :baz }.should raise_error(klass, /frozen/)
      lambda { @opts.trailing_non_opts << :baz }.should raise_error(klass, /frozen/)
    end
  end

  describe 'parsing' do
    it 'should not set non-existant switches' do
      opt :foo
      parse('--foo')[:bar].should be_nil
      parse[:foo].should be_nil
    end

    it 'should extract non-option arguments which are not switches' do
      opt(:foo) { required true }
      opt(:bar) { cast TrueClass }
      opts = parse('foo', 'bar', '--foo', '12', '--bar', 'bang', 'bong')

      opts.should == { 'foo' => '12', 'bar' => true }
      opts.leading_non_opts.should  == ['foo', 'bar']
      opts.trailing_non_opts.should == ['bang', 'bong']
    end

    it 'should raise an error when a switch is encountered which has not been defined' do
      lambda { parse('--foo') }.should raise_error(Imp::InvalidSwitch)
    end

    describe 'with no arguments' do
      it 'should return an empty hash when there are no options defined' do
        parse.should == {}
      end

      it 'should return an empty hash if there are several options defined' do
        opt(:foo) { cast TrueClass }
        opt(:bar)
        parse.should == {}
      end

      it 'should raise an error if there is a required option defined' do
        opt(:foo) { required true }
        opt(:bar) { required true }
        lambda { parse }.should raise_error(Imp::MissingRequiredOption,
          /(--foo, --bar)|(--bar, --foo)/)
      end
    end

    describe 'with several optional switches' do
      before :each do
        opt :foo, :bar
      end

      it 'should set switches with no arguments to true' do
        parse('--foo')[:foo].should be_true
        parse('--bar')[:bar].should be_true
      end

      it 'should not set switches which are not present' do
        parse('--foo')[:bar].should be_nil
        parse('--bar')[:foo].should be_nil
      end

      it 'should set switches with values to the given value' do
        parse('--foo', '12')[:foo].should == '12'
        parse('--bar', '12')[:bar].should == '12'
      end

      it 'should assume that something which could be a switch or value is a switch' do
        opts = parse('--foo', '--bar')
        opts[:foo].should be_true
        opts[:bar].should be_true
      end

      it 'should overwrite earlier values with later ones' do
        parse("--foo", "--foo", "12")[:foo].should == "12"
        parse("--foo", "12", "--foo", "13")[:foo].should == "13"
      end
    end

    describe 'with one required and one optional switch' do
      before :each do
        opt(:foo) { required true }
        opt(:bar)
      end

      it 'should raise an error if the required switch has no value' do
        lambda { parse('--foo') }.should raise_error(
          Imp::OptionError, /requires a value/)
      end

      it 'should raise an error if the required switch is not present' do
        lambda { parse }.should raise_error(Imp::MissingRequiredOption)
      end

      it 'should raise an error if the switch is given another switch as the value' do
        lambda { parse('--foo', '--bar') }.should raise_error(
          Imp::OptionError, /requires a value/)
      end
    end

    describe 'with optional switches which have default values' do
      before :each do
        opt(:foo) { default '12' }
        opt(:bar) { default false }
        opt(:baz) { default nil }
      end

      it 'should override the default with a specified value' do
        opts = parse('--foo', '13', '--bar', '--baz')
        opts[:foo].should == '13'
        opts[:bar].should be_true
        opts[:baz].should be_true
      end

      it 'should use the default when an value is not specified' do
        opts = parse
        opts[:foo].should == '12'
        opts[:bar].should == false
        opts[:baz].should == nil
      end
    end

    describe 'with an option which is typecasted to a Numeric' do
      before :each do
        opt(:foo) { cast Numeric }
      end

      it 'should typecast an integer-like value to an Integer' do
        parse('--foo', '12')[:foo].should == 12
      end

      it 'should typecast a float-like value to an Float' do
        parse('--foo', '12.1')[:foo].should == 12.1
      end

      it 'should raise an error if the value could not be typecast' do
        lambda {
          parse('--foo', 'a')[:foo]
        }.should raise_error(Imp::OptionError, /numeric argument/)
      end

      it 'should raise an error if the switch is present but no value is given' do
        lambda {
          parse('--foo')[:foo]
        }.should raise_error(Imp::OptionError, /requires a value/)
      end

      it 'should not raise an error if the switch is not present' do
        lambda { parse }.should_not raise_error
      end
    end
  end
end

#
# Mash specs.
#

describe Imp::Options::Mash do
  describe '#initialize' do
    it 'should add the given symbol attributes to the Mash' do
      mash = Imp::Options::Mash.new(:one => :two, :foo => :bar)
      mash[:one].should == :two
      mash[:foo].should == :bar
    end

    it 'should add the given string attributes to the Mash' do
      mash = Imp::Options::Mash.new('one' => :two, 'foo' => :bar)
      mash['one'].should == :two
      mash['foo'].should == :bar
    end

    it 'should return an empty Mash if no arguments are given' do
      lambda { Imp::Options::Mash.new }.should_not raise_error(TypeError)
      lambda { Imp::Options::Mash.new(nil) }.should_not raise_error(TypeError)
      Imp::Options::Mash.new.keys.length.should == 0
    end
  end

  describe '#[]' do
    before(:each) do
      @mash = Imp::Options::Mash.new(:symbol => 1, 'string' => 2)
    end

    describe 'when passing in a symbol' do
      it 'should retrieve a key defined as a symbol' do
        @mash[:symbol].should == 1
      end

      it 'should retrieve a key defined as a string' do
        @mash[:string].should == 2
      end
    end

    describe 'when passing in a string' do
      it 'should retrieve a key defined as a symbol' do
        @mash['symbol'].should == 1
      end

      it 'should retrieve a key defined as a string' do
        @mash['string'].should == 2
      end
    end
  end
end

#
# Option generator specs.
#

describe Imp::Options::Option::Generator do
  before :each do
    @methods = if RUBY_VERSION < '1.9'
      Imp::Options::Option::Generator.instance_methods.map { |m| m.to_sym }
    else
      Imp::Options::Option::Generator.instance_methods
    end
  end

  it 'should have a long method' do
    @methods.should include(:long)
  end

  it 'should have a short method' do
    @methods.should include(:short)
  end

  it 'should have a default method' do
    @methods.should include(:default)
  end

  it 'should have a cast method' do
    @methods.should include(:cast)
  end

  it 'should have a description method' do
    @methods.should include(:description)
  end

  it 'should have a required method' do
    @methods.should include(:required)
  end
end

#
# Option specs.
#

describe Imp::Options::Option do
  describe '#define' do
    it 'should return an Imp::Options::Option instance' do
      opt = Imp::Options::Option.define(:field)
      opt.should be_kind_of(Imp::Options::Option)
    end

    it 'should set the Option name' do
      opt = Imp::Options::Option.define(:field)
      opt.name.should == :field
    end

    describe 'when no configuration block is given' do
      before(:each) do
        @opt = Imp::Options::Option.define(:field)
      end

      it 'should automatically set a long name' do
        @opt.long.should == '--field'
      end

      it 'should automatically set a short name' do
        @opt.short.should == '-f'
      end

      it 'should not set a default' do
        @opt.default.should be_nil
      end

      it 'should not set a cast' do
        @opt.cast.should be_nil
      end

      it 'should not set a description' do
        @opt.description.should be_nil
      end

      it 'should not set a requirement' do
        @opt.required.should be_nil
      end
    end

    describe 'when a configuration block is given' do
      before(:each) do
        @opt = Imp::Options::Option.define(:field) do
          long        '--long'
          short       '-s'
          default     10
          cast        Integer
          description 'My description'
          required    true
        end
      end

      it 'should set the name' do
        @opt.name.should == :field
      end

      it 'should set the long name' do
        @opt.long.should == '--long'
      end

      it 'should set the short name' do
        @opt.short.should == '-s'
      end

      it 'should set the default' do
        @opt.default.should == 10
      end

      it 'should set the cast' do
        @opt.cast.should == Integer
      end

      it 'should set the description' do
        @opt.description.should == 'My description'
      end

      it 'should set the requirement' do
        @opt.required.should be_true
      end

      describe 'and no short setting is present' do
        it 'should set the short setting using the long setting' do
          @opt = Imp::Options::Option.define(:field) do
            long        '--long'
            default     10
            cast        Integer
            description 'My description'
          end

          @opt.short.should == '-l'
        end
      end

      describe 'and explicitly setting the short setting to nil' do
        it 'should not auto-set the short setting' do
          @opt = Imp::Options::Option.define(:field) do
            short       nil
            long        '--long'
            default     10
            cast        Integer
            description 'My description'
          end

          @opt.short.should be_nil
        end
      end

      describe 'and a default is set but no cast is set' do
        it 'should set the cast to the default class' do
          @opt = Imp::Options::Option.define(:field) do
            default 10
          end

          @opt.cast.should == Fixnum
        end

        it 'should set the cast to TrueClass when the default is true' do
          @opt = Imp::Options::Option.define(:field) do
            default true
          end

          @opt.cast.should == TrueClass
        end

        it 'should set the cast to FalseClass when the default is true' do
          @opt = Imp::Options::Option.define(:field) do
            default false
          end

          @opt.cast.should == FalseClass
        end
      end
    end
  end # describe '#define'

end
