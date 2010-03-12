require 'spec_helper'

describe Plastic, "validations" do
  describe "#valid_expiration_month?" do
    it "is true when the month is any of 1-12" do
      (1..12).each do |month|
        expiration = "YY%02d" % month
        expiration.should match(/^YY[01]\d$/)
        Plastic.new(:expiration => expiration).should be_valid_expiration_month
      end
    end

    it "is false when the month is outside the range 1-12" do
      [0, 17, 31].each do |month|
        expiration = "YY%02d" % month
        expiration.should match(/^YY\d\d$/)
        Plastic.new(:expiration => expiration).should_not be_valid_expiration_month
      end
    end
  end
end