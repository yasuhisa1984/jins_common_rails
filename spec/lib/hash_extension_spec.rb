require 'spec_helper'
require 'hash_extension'

describe "Extension for Hash" do
  before(:each) do
    @h = Hash.new
  end
  
  describe 'method_missing' do
    it "getter" do
      @h.foo.should == nil
    end
    it "setter" do
      @h.foo = "bar"
      @h.foo.should == "bar"
    end
  end
end