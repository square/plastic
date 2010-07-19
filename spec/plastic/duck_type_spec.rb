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
    [:security_code, :cvv2],
    [:expiration_date, :expiration],
    [:track1, :track_1],
    [:track2, :track_2],
  ].each do |_alias, method|
    it "##{method} is aliased as ##{_alias}" do
      @instance.method(_alias).should == @instance.method(method)
    end

    it "##{method} is aliased as ##{_alias}" do
      @instance.method("#{_alias}=").should == @instance.method("#{method}=")
    end

    it "##{method}? checks blankness of ##{_alias}" do
      @instance.send(:"#{_alias}?").should be_false
    end
  end

  describe "when expiration is set" do
    before do
      @instance.expiration = "1501"
    end

    describe "#year" do
      it "returns the two digit year as a string" do
        @instance.expiration_year.should == 2015
        @instance.year.should == "15"
      end
    end

    describe "#month" do
      it "returns the two digit month as a string" do
        @instance.expiration_month.should == 1
        @instance.month.should == "01"
      end
    end
  end

  describe "when expiration is not set" do
    describe "#year" do
      it "returns nil" do
        @instance.year.should be_nil
      end
    end

    describe "#month" do
      it "returns nil" do
        @instance.month.should be_nil
      end
    end
  end
end
