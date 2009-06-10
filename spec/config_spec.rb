require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Imp::Config do
  after :each do
    Imp::Config.setup
  end

  describe '#[]' do
    it 'should return a value if the argument matches a key' do
      Imp::Config.setup(:hi => :ho)
      Imp::Config[:hi].should == :ho
    end

    it 'should return a default if applicable' do
       Imp::Config[:in].should_not be_nil
    end

    it 'should return nil if the argument does not match a key' do
      Imp::Config[:illegal].should be_nil
    end
  end

  #

  describe '#[]=' do
    it 'should set a key to the given value' do
      Imp::Config[:hi] = :ho
      Imp::Config[:hi].should == :ho
    end

    it 'should overwrite existing values' do
      Imp::Config[:hi] = :ho
      Imp::Config[:hi] = :off_to_work_we_go
      Imp::Config[:hi].should == :off_to_work_we_go
    end

    it 'should overwrite default values' do
      Imp::Config[:in] = :out
      Imp::Config[:in].should == :out
    end
  end

  #

  describe '#has_key?' do
    it 'should return true if the Config has the given key' do
      Imp::Config.has_key?(:in).should be_true
    end

    it 'should return false if the Config does not have the key' do
      Imp::Config.has_key?(:illegal).should be_false
    end
  end

  #

  describe '#delete' do
    it 'should remove the given key and return its value' do
      Imp::Config[:hi] = :ho
      Imp::Config.delete(:hi).should == :ho
      Imp::Config.should_not have_key(:hi)
    end

    it 'should return nil if the key does not exist' do
      Imp::Config.delete(:hi).should be_nil
    end
  end

  #

  describe '#fetch' do
    it 'should return the value for the given key' do
      Imp::Config[:hi] = :ho
      Imp::Config.fetch(:hi, :go).should == :ho
    end

    it 'should return the default if no value is present' do
      Imp::Config.fetch(:hi, :ho).should == :ho
    end
  end

end
