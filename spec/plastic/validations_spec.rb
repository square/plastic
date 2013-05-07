require 'spec_helper'

describe Plastic, "validations" do
  describe "#valid_pan?" do
    subject { Plastic.new(:pan => "4111111111111111") }

    it "is false if the pan is not present" do
      subject.pan = ""
      subject.should_not be_valid_pan
      subject.errors.should == ["PAN not present"]
    end

    it "is true when #valid_pan_length? and #valid_pan_checksum? are true" do
      subject.should be_valid_pan
    end

    it "is false when #valid_pan_length? is false" do
      subject.pan = "411"
      subject.should_not be_valid_pan_length
      subject.errors.should == ["PAN is too short"]
    end

    it "is false when #valid_pan_checksum? is false" do
      subject.pan = "4111111111111112"
      subject.should_not be_valid_pan
      subject.errors.should == ["PAN does not pass checksum"]
    end

    it "is false when only letters are passed in" do
      subject.pan = "INVALID_PAYMENT_NUMBER"
      subject.should_not be_valid_pan
      subject.errors.should == ["PAN contains non-digit characters"]
    end
  end

  describe "#valid_expiration?" do
    subject { Plastic.new(:expiration => "1312") }

    it "is false when set to last year" do
      freeze_time!(Time.utc(2002, 01, 25))
      plastic = Plastic.new(:expiration => '0101', :pan => "4111111111111111")
      plastic.should_not be_valid
      plastic.errors.should == ["Card has expired"]
    end

    it "is false when set 21 years in the future" do
      freeze_time!(Time.utc(2001, 01, 25))
      plastic = Plastic.new(:expiration => '2201', :pan => "4111111111111111")
      plastic.should_not be_valid
      plastic.errors.should == ["Card has expired"]
    end

    it "is false when set to 20 years in the past" do
      freeze_time!(Time.utc(2001, 01, 25))
      plastic = Plastic.new(:expiration => '8101', :pan => "4111111111111111")
      plastic.should_not be_valid
      plastic.errors.should == ["Card has expired"]
    end

    it "is false if the expiration is nil" do
      subject.expiration = nil
      subject.should_not be_valid_expiration
      subject.errors.should == ["Expiration not present"]
    end

    it "is false if the expiration is not present" do
      subject.expiration = ""
      subject.should_not be_valid_expiration
      subject.errors.should == ["Expiration not present"]
    end

    it "is false if the expiration is elided" do
      subject.expiration = "="
      subject.should_not be_valid_expiration
      subject.errors.should == ["Expiration not present"]
    end

    it "is valid on the first day of the month in UTC when expiry is the previous month" do
      freeze_time!(Time.utc(2013, 03, 01, 12, 59))
      plastic = Plastic.new(:expiration => '1302', :pan => "4111111111111111")
      plastic.should be_valid_expiration
      plastic.errors.should_not == ["Card has expired"]
    end

    it "is not valid on the second day of the month in UTC when expiry is the previous month" do
      freeze_time!(Time.utc(2013, 03, 02))
      plastic = Plastic.new(:expiration => '1302', :pan => "4111111111111111")
      plastic.should_not be_valid_expiration
      plastic.errors.should == ["Card has expired"]
    end

    describe "when expiration_year is next year" do
      it "is true for all values of expiration_month" do
        next_year = (DateTime.now.year + 1).to_s[-2..-1]
        (1..12).each do |month|
          subject.expiration = "%02d%02d" % [next_year, month]
          subject.should be_valid_expiration
        end
      end
    end

    describe "when expiration_year is this year" do
      before do
        @this_year = DateTime.now.year.to_s[-2..-1]
      end

      it "is true when expiration_month is this month and after" do
        (DateTime.now.month..12).each do |month|
          subject.expiration = "%02d%02d" % [@this_year, month]
          subject.should be_valid_expiration
        end
      end

      it "is false when expiration_month is earlier than this month" do
        this_year = DateTime.now.year.to_s[-2..-1]
        (1...DateTime.now.month).each do |month|
          subject.errors.clear
          subject.expiration = "%02d%02d" % [@this_year, month]
          subject.should_not be_valid_expiration
          subject.errors.should == ["Card has expired"]
        end
      end
    end

    it "is false when #valid_expiration_year? is false" do
      subject.should_receive(:valid_expiration_year?).and_return(false)
      subject.should_not be_valid_expiration
    end

    it "is false when #valid_expiration_month? is false" do
      subject.should_receive(:valid_expiration_month?).and_return(false)
      subject.should_not be_valid_expiration
    end
  end

  describe "valid_pan_length?" do
    it "is true when card number is 12 or more digits" do
      extra_numbers = %w[11 234 5678 99999999].each do |n|
        Plastic.new(:pan => "0123456789#{n}").should be_valid_pan_length
      end
    end

    it "is false when card number is less than 12 digits" do
      plastic = Plastic.new(:pan => "0123456789")
      plastic.should_not be_valid_pan_length
      plastic.errors.should == ["PAN is too short"]

      plastic = Plastic.new(:pan => "01234567890")
      plastic.should_not be_valid_pan_length
      plastic.errors.should == ["PAN is too short"]
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
        plastic = Plastic.new(:pan => pan)
        plastic.should_not be_valid_pan_checksum
        plastic.errors.should == ["PAN does not pass checksum"]
      end
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
        plastic = Plastic.new(:expiration => expiration)
        plastic.should_not be_valid_expiration_month
        plastic.errors.should == ["Invalid expiration month"]
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

    it "is false when set to a string" do
      Plastic.new(:expiration => 'ab01').should_not be_valid_expiration_year
    end
  end

  describe "#valid_brand?" do
    it "is not valid if the brand is blank" do
      plastic = Plastic.new(:pan => "0480020605154711", :expiration => "1312")
      plastic.stub!(:valid_pan?).and_return(true)
      plastic.should_not be_valid
      plastic.errors.should == ["Unknown card brand"]
    end
  end

  describe "#valid?" do
    before do
      @plastic = Plastic.new(:pan => "5480020605154711", :expiration => "1501")
    end

    it "is valid if it has both a valid pan and an expiration" do
      @plastic.should be_valid
    end

    it "is not valid if the pan is missing" do
      @plastic.pan = nil
      @plastic.should_not be_valid
    end

    it "is not valid if the expiration is missing" do
      @plastic.expiration = nil
      @plastic.should_not be_valid
    end

    it "is not valid if the card is expired" do
      @plastic.expiration = "0901"
      @plastic.should_not be_valid
    end

    it "is not valid if the pan does not pass its checksum" do
      @plastic.pan = "4001111111111"
      @plastic.should_not be_valid
    end

    it "clears the errors before running" do
      @plastic.errors << "some error"
      @plastic.should be_valid
      @plastic.errors.should be_empty
    end
  end
end
