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

  describe "#valid_expiration_year?" do
    def format_expiration_year_as_track(year)
      two_digit_year = year.to_s[-2..-1].to_i % 99
      expiration = "%02dMM" % two_digit_year
      expiration.should match(/^\d\dMM$/)
      expiration
    end

    before do
      @this = DateTime.now
    end

    it "is true when set to the current year and up to 20 years later" do
      (@this.year..@this.year + 20).each do |year|
        expiration = format_expiration_year_as_track(year)
        Plastic.new(:expiration => expiration).should be_valid_expiration_year
      end
    end

    it "is false when set to last year" do
      invalid_year = DateTime.now.year - 1
      expiration = format_expiration_year_as_track(invalid_year)
      Plastic.new(:expiration => expiration).should_not be_valid_expiration_year
    end

    it "is false when set 21 years in the future" do
      invalid_year = DateTime.now.year + 21
      expiration = format_expiration_year_as_track(invalid_year)
      Plastic.new(:expiration => expiration).should_not be_valid_expiration_year
    end
  end
end