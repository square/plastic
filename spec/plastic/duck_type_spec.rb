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
    [:verification_value?, :cvv2],
    [:track1, :track_1],
    [:track2, :track_2],
  ].each do |_alias, method|
    it "##{method} is aliased as ##{_alias}" do
      @instance.method(_alias).should == @instance.method(method)
    end
  end

  # TODO: spec #year
  # TODO: spec #month
end
