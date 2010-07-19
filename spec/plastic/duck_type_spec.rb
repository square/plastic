require File.dirname(__FILE__) + '/../spec_helper'

describe Plastic do
  subject { described_class.new }

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
      subject.method(_alias).should == subject.method(method)
    end

    it "##{method} is aliased as ##{_alias}" do
      subject.method("#{_alias}=").should == subject.method("#{method}=")
    end

    it "##{method}? checks blankness of ##{_alias}" do
      subject.send(:"#{_alias}?").should be_false
    end
  end

  describe "when expiration is set" do
    before do
      subject.expiration = "1501"
    end

    describe "#year" do
      it "returns the two digit year as a string" do
        subject.expiration_year.should == 2015
        subject.year.should == "15"
      end
    end

    describe "#month" do
      it "returns the two digit month as a string" do
        subject.expiration_month.should == 1
        subject.month.should == "01"
      end
    end
  end

  describe "when expiration is not set" do
    describe "#year" do
      it "returns nil" do
        subject.year.should be_nil
      end
    end

    describe "#month" do
      it "returns nil" do
        subject.month.should be_nil
      end
    end
  end
end
