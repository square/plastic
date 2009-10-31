require File.dirname(__FILE__) + '/../spec_helper'

describe Plastic do
  before :each do
    @instance = described_class.new
  end

  [
    [:number, :pan],
    [:first_name, :given_name],
    [:last_name, :surname],
    [:verification_value, :cvv2],
    [:track1, :track_1],
    [:track2, :track_2],
  ].each do |_alias, method|
    it "##{_alias} calls ##{method}" do
      @instance.should_receive(method).with.once.and_return("foo")
      @instance.send(_alias).should == "foo"
    end
  end

  # TODO: spec #year
  # TODO: spec #month
end
