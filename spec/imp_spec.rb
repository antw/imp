require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Imp::VERSION' do
  it 'should be a string' do
    Imp::VERSION.should be_kind_of(String)
  end

  it 'should contain only numbers and dots' do
    Imp::VERSION.should     =~ /\A[\d\.]+\Z/
    Imp::VERSION.should_not =~ /\n/
  end
end
