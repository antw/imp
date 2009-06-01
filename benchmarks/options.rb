require 'rubygems'
require 'rbench'

require File.join(File.dirname(__FILE__), '..', 'lib', 'imp')

puts
puts "Benchmarking option definition..."

TIMES = 10_000

RBench.run(TIMES) do

  format :width => 80

  report('Defining nothing') do
    Imp::Options::OptionParser.new
  end

  report('Defining one option without configuration') do
    parser = Imp::Options::OptionParser.new([
      Imp::Options::Option.define(:foo)
    ])
  end

  report('Defining one option with configuration') do
    Imp::Options::OptionParser.new([
      Imp::Options::Option.define(:foo) do
        long        '--long'
        short       '-s'
        required    true
        default     true
        cast        TrueClass
        description 'Hello'
      end
    ])
  end

  summary "Total"
end

puts
puts "Benchmarking option parsing..."

RBench.run(TIMES) do

  format :width => 80

  @_opt_parser = Imp::Options::OptionParser.new([
    Imp::Options::Option.define(:one),
    Imp::Options::Option.define(:two),
    Imp::Options::Option.define(:three),
    Imp::Options::Option.define(:four),
    Imp::Options::Option.define(:force),
    Imp::Options::Option.define(:bool) { cast TrueClass },
    Imp::Options::Option.define(:num)  { cast Numeric },
  ])

  report('With one switch present') do
    @_opt_parser.parse(['--bool'])
  end

  report('With both switches present') do
    @_opt_parser.parse(['--force', '--bool'])
  end

  report('With short-form switches') do
    @_opt_parser.parse(['-f', '-b'])
  end

  report('With conjoined short-form switches') do
    @_opt_parser.parse(['-fb'])
  end

  report('With two leading non-opts') do
    @_opt_parser.parse(['one', 'two', '--force', '--bool'])
  end

  report('With two trailing non-opts') do
    @_opt_parser.parse(['--force', '--bool', 'one', 'two'])
  end

  report('With mixed options') do
    @_opt_parser.parse(['a', 'b' '--force', '-b', '-ot', '--num=4', '--two', 'trail'])
  end

end
