require File.dirname(__FILE__) + '/../spec_helper'

describe Plastic do
  before :each do
    @instance = described_class.new
  end

  it "#number calls #pan" do
    @instance.should_receive(:pan).with.once.and_return("foo")
    @instance.number.should == "foo"
  end

  # TODO: spec #year
  # TODO: spec #month

  it "#first_name calls #given_name" do
    @instance.should_receive(:given_name).with.once.and_return("foo")
    @instance.first_name.should == "foo"
  end

  it "#last_name calls #surname" do
    @instance.should_receive(:surname).with.once.and_return("foo")
    @instance.last_name.should == "foo"
  end
end
