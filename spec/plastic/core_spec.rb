require File.dirname(__FILE__) + '/../spec_helper'

class OtherHash < Hash
end

describe Plastic do
  subject { described_class.new }

  [
    :pan, :expiration,
    :track_name, :surname, :given_name, :title,
    :service_code, :cvv2,
    :track_1, :track_2,
  ].each do |accessor|
    it "has accessor :#{accessor} and :#{accessor}=" do
      subject.should respond_to(:"#{accessor}")
      subject.should respond_to(:"#{accessor}=")
    end
  end

  describe "new" do
    it "returns an instance of #{described_class.name}" do
      subject.should be_instance_of(described_class)
    end
  end

  describe "#initialize" do
    context "with no arguments" do
      it "calls update! with an empty hash" do
        subject.should_receive(:update!).with({})
        subject.send :initialize
      end
    end

    context "with a nil argument" do
      it "calls parse_track!" do
        subject.should_receive(:parse_track!).with(nil)
        subject.send :initialize, nil
      end
    end

    context "with a hash argument" do
      subject { described_class.new(:track_1 => "%B123456789012345^Dorsey/Jack.Dr^1010123?") }
      
      it "calls update! with the hash argument" do
        arg = {:foo => "bar"}
        subject.should_receive(:update!).with(arg)
        subject.send :initialize, arg
      end

      it "parses the track data if given" do
        subject.track_1.should == "%B123456789012345^Dorsey/Jack.Dr^1010123?"
        subject.pan.should == "123456789012345"
        subject.expiration.should == "1010"
        subject.name.should == "Dr Jack Dorsey"
      end
    end

    context "with a string argument" do
      it "calls parse_track! with the string argument" do
        arg = "foo=bar"
        subject.should_receive(:parse_track!).with(arg)
        subject.send :initialize, arg
      end
    end
  end

  describe "#update!" do
    context "with no arguments" do
      it "calls update! with an empty hash" do
        subject.should_not_receive(:send)
        subject.update!
      end
    end

    context "with a nil argument" do
      it "raises an exception" do
        expect { subject.update! nil }.to raise_error(NoMethodError)
      end
    end

    context "with a hash argument" do
      it "assigns the passed keys" do
        arg = {:pan => "bar"}
        subject.update! arg
        subject.pan.should == "bar"
      end

      it "ignores parameters that do not correspond to a setter" do
        subject.should_not respond_to(:foo=)
        expect { subject.update! :foo => 97 }.to_not raise_error
      end
    end

    context "with a subclass of hash" do
      before do
        @other_hash = OtherHash.new
        @other_hash[:pan] = "bar"
        @other_hash.should be_kind_of(Hash)
      end

      it "assigns the passed keys" do
        subject.update! @other_hash
        subject.pan.should == "bar"
      end
    end
  end

  describe "#name" do
    it "returns a string" do
      subject.name.should be_instance_of(String)
    end

    [
      ["Prince", nil, nil, "Prince"],
      ["Walters", "Cameron", nil, "Cameron Walters"],
      ["Howser", "Doogie", "Dr", "Dr Doogie Howser"],
    ].each do |surname, given_name, title, name|
      it "returns #{name} for the given input" do
        subject.surname = surname
        subject.given_name = given_name
        subject.title = title
        subject.name.should == name
      end
    end
  end

  describe "#expiration_year" do
    it "returns a year 2000s when two digit expiration is in the range 00-68, inclusive" do
      (0..68).each do |y|
        yy = "%02d" % y
        Plastic.new(:expiration => "#{yy}01").expiration_year.should == 2000 + y
      end
    end

    it "returns a year in 1900s when when two digit expiration is in the range 69-99, inclusive" do
      (69..99).each do |y|
        yy = "%02d" % y
        Plastic.new(:expiration => "#{yy}01").expiration_year.should == 1900 + y
      end
    end
  end

  describe "expiration_month" do
    it "returns an integer month" do
      subject.expiration = "9901"
      subject.expiration_month.should == 1
      subject.expiration = "9912"
      subject.expiration_month.should == 12
    end
  end

  describe "#brand" do
    it "recognizes Visa cards" do
      Plastic.new(:pan => "4111111111111111").brand.should == :visa
    end

    it "does not recognize pseudo-Visa cards with 13, 14, 15, or 17 digits" do
      # Visa once used 13-digit PANs, but these accounts have all been migrated
      # to 16-digit PANs. The old numbers are not valid for new transactions.
      Plastic.new(:pan => "4111111111111").brand.should_not == :visa
      Plastic.new(:pan => "41111111111111").brand.should_not == :visa
      Plastic.new(:pan => "411111111111111").brand.should_not == :visa
      Plastic.new(:pan => "41111111111111111").brand.should_not == :visa
    end

    it "recognizes MasterCard cards" do
      Plastic.new(:pan => "5100000000000000").brand.should == :mastercard
      Plastic.new(:pan => "5200000000000000").brand.should == :mastercard
      Plastic.new(:pan => "5300000000000000").brand.should == :mastercard
      Plastic.new(:pan => "5400000000000000").brand.should == :mastercard
      Plastic.new(:pan => "5500000000000000").brand.should == :mastercard
      # TODO: confirm that 677189- is really MasterCard
      Plastic.new(:pan => "6771890000000000").brand.should == :mastercard
    end

    it "does not recognize pseudo-MasterCards with invalid IINs" do
      Plastic.new(:pan => "5000000000000000").brand.should_not == :mastercard
      Plastic.new(:pan => "5600000000000000").brand.should_not == :mastercard
      Plastic.new(:pan => "5700000000000000").brand.should_not == :mastercard
      Plastic.new(:pan => "5800000000000000").brand.should_not == :mastercard
      Plastic.new(:pan => "5900000000000000").brand.should_not == :mastercard
    end

    it "does not recognize pseudo-MasterCards with 15 or 17 digits" do
      Plastic.new(:pan => "510000000000000").brand.should_not == :mastercard
      Plastic.new(:pan => "520000000000000").brand.should_not == :mastercard
      Plastic.new(:pan => "53000000000000000").brand.should_not == :mastercard
      Plastic.new(:pan => "54000000000000000").brand.should_not == :mastercard
      # TODO: confirm that 677189- is really MasterCard
      Plastic.new(:pan => "677189000000000").brand.should_not == :mastercard
      Plastic.new(:pan => "67718900000000000").brand.should_not == :mastercard
    end

    it "recognizes Discover cards" do
      Plastic.new(:pan => "6011000000000000").brand.should == :discover
      Plastic.new(:pan => "6440000000000000").brand.should == :discover
      Plastic.new(:pan => "6450000000000000").brand.should == :discover
      Plastic.new(:pan => "6460000000000000").brand.should == :discover
      Plastic.new(:pan => "6470000000000000").brand.should == :discover
      Plastic.new(:pan => "6480000000000000").brand.should == :discover
      Plastic.new(:pan => "6490000000000000").brand.should == :discover
      Plastic.new(:pan => "6500000000000000").brand.should == :discover
    end

    it "does not recognize pseudo-Discover cards with 15 digits" do
      Plastic.new(:pan => "601100000000000").brand.should_not == :discover
      Plastic.new(:pan => "644000000000000").brand.should_not == :discover
      Plastic.new(:pan => "645000000000000").brand.should_not == :discover
      Plastic.new(:pan => "646000000000000").brand.should_not == :discover
      Plastic.new(:pan => "647000000000000").brand.should_not == :discover
      Plastic.new(:pan => "648000000000000").brand.should_not == :discover
      Plastic.new(:pan => "649000000000000").brand.should_not == :discover
      Plastic.new(:pan => "650000000000000").brand.should_not == :discover
    end

    it "does not recognize pseudo-Discover cards with 17 digits" do
      Plastic.new(:pan => "60110000000000000").brand.should_not == :discover
      Plastic.new(:pan => "64400000000000000").brand.should_not == :discover
      Plastic.new(:pan => "64500000000000000").brand.should_not == :discover
      Plastic.new(:pan => "64600000000000000").brand.should_not == :discover
      Plastic.new(:pan => "64700000000000000").brand.should_not == :discover
      Plastic.new(:pan => "64800000000000000").brand.should_not == :discover
      Plastic.new(:pan => "64900000000000000").brand.should_not == :discover
      Plastic.new(:pan => "65000000000000000").brand.should_not == :discover
    end

    it "recognizes American Express cards" do
      Plastic.new(:pan => "340000000000000").brand.should == :american_express
      Plastic.new(:pan => "370000000000000").brand.should == :american_express
    end

    it "does not recognize pseudo-American Express cards with 14 or 16 digits" do
      Plastic.new(:pan => "34000000000000").brand.should_not == :american_express
      Plastic.new(:pan => "37000000000000").brand.should_not == :american_express
      Plastic.new(:pan => "3400000000000000").brand.should_not == :american_express
      Plastic.new(:pan => "3700000000000000").brand.should_not == :american_express
    end

    it "recognizes JCB cards" do
      Plastic.new(:pan => "3540123456789012").brand.should == :jcb
      Plastic.new(:pan => "3528000000000000").brand.should == :jcb
      Plastic.new(:pan => "3589990000000000").brand.should == :jcb
    end

    it "does not recognize pseudo-JCB cards with 15 or 17 digits" do
      Plastic.new(:pan => "354012345678901").brand.should_not == :jcb
      Plastic.new(:pan => "352800000000000").brand.should_not == :jcb
      Plastic.new(:pan => "358999000000000").brand.should_not == :jcb
      Plastic.new(:pan => "35401234567890123").brand.should_not == :jcb
      Plastic.new(:pan => "35280000000000000").brand.should_not == :jcb
      Plastic.new(:pan => "35899900000000000").brand.should_not == :jcb
    end

    it "recognizes Discover Diner's cards" do
      Plastic.new(:pan => "38520000023237").brand.should == :discover_diners
      Plastic.new(:pan => "30000000000004").brand.should == :discover_diners
      Plastic.new(:pan => "30569309025904").brand.should == :discover_diners
    end

    it "recognizes China UnionPay as Discover" do
      Plastic.new(:pan => "6242000000000000").brand.should == :discover
    end
  end

  describe "BRANDS constant" do
    it "returns a list of the brands as symbols" do
      Plastic::BRANDS.should == [:visa, :mastercard, :american_express,
                                 :discover, :discover_diners, :jcb]
    end
  end
end
