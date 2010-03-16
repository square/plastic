require 'spec_helper'

describe Plastic, "validations" do
  describe "valid_pan_length?" do
    it "is true when card number is 12 or more digits" do
      extra_numbers = %w[11 234 5678 99999999].each do |n|
        Plastic.new(:pan => "0123456789#{n}").should be_valid_pan_length
      end
    end

    it "is false when card number is less than 12 digits" do
      Plastic.new(:pan => "0123456789").should_not be_valid_pan_length
      Plastic.new(:pan => "01234567890").should_not be_valid_pan_length
    end
  end

  describe "valid_pan_checksum?" do
    %w[
      5454545454545454
      5480020605154711
      3566002020190001
      4111111111111111
      4005765777003
      371449635398456
      6011000995504101
      36438999910011
      4055011111111111
      5581111111111119
    ].each do |pan|
      it "is true with valid test PAN #{pan}" do
        Plastic.new(:pan => pan).should be_valid_pan_checksum
      end
    end

    %w[
      5451666666666666
      5480000000000000
      3566333333333333
      4222222222222222
      4001111111111
      371433333333333
      6011444444444444
      36435555555555
      4055999999999999
      5581777777777777
    ].each do |pan|
      it "is false with invalid PAN #{pan}" do
        Plastic.new(:pan => pan).should_not be_valid_pan_checksum
      end
    end
  end

  describe "#valid_pan?" do
    before do
      @card = Plastic.new(:pan => "4111111111111111")
    end

    it "is true when #valid_pan_length? and #valid_pan_checksum? are true" do
      @card.should be_valid_pan
    end

    it "is false when #valid_pan_length? is false" do
      @card.should_receive(:valid_pan_length?).and_return(false)
      @card.should_not be_valid_pan
    end

    it "is false when #valid_pan_checksum? is false" do
      @card.should_receive(:valid_pan_checksum?).and_return(false)
      @card.should_not be_valid_pan
    end
  end

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

  describe "#valid_expiration?" do
    before do
      @card = Plastic.new(:expiration => "1312")
    end

    it "is true when #valid_expiration_year? and #valid_expiration_month? are true" do
      @card.should be_valid_expiration
    end

    it "is false when #valid_expiration_year? is false" do
      @card.should_receive(:valid_expiration_year?).and_return(false)
      @card.should_not be_valid_expiration
    end

    it "is false when #valid_expiration_month? is false" do
      @card.should_receive(:valid_expiration_month?).and_return(false)
      @card.should_not be_valid_expiration
    end
  end
end