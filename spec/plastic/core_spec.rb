require File.dirname(__FILE__) + '/../spec_helper'

class OtherHash < Hash
end

describe Plastic do
  before :each do
    @instance = described_class.new
  end

  [
    :pan, :expiration,
    :track_name, :surname, :given_name, :title,
    :service_code, :cvv2,
    :track_1, :track_2,
    :expiration_month, :expiration_year
  ].each do |accessor|
    it "has accessor :#{accessor} and :#{accessor}=" do
      @instance.should respond_to(:"#{accessor}")
      @instance.should respond_to(:"#{accessor}=")
    end
  end

  describe "new" do
    it "returns an instance of #{described_class.name}" do
      @instance.should be_instance_of(described_class)
    end
  end

  describe "#initialize" do
    context "with no arguments" do
      it "calls update! with an empty hash" do
        @instance.should_receive(:update!).with({})
        @instance.send :initialize
      end
    end

    context "with a nil argument" do
      it "calls parse_track!" do
        @instance.should_receive(:parse_track!).with(nil)
        @instance.send :initialize, nil
      end
    end

    context "with a hash argument" do
      it "calls update! with the hash argument" do
        arg = {:foo => "bar"}
        @instance.should_receive(:update!).with(arg)
        @instance.send :initialize, arg
      end

      it "parses the track data if given" do
        instance = described_class.new(:track_1 => "%B123456789012345^Dorsey/Jack.Dr^1010123?")
        instance.track_1.should == "%B123456789012345^Dorsey/Jack.Dr^1010123?"
        instance.pan.should == "123456789012345"
        instance.expiration.should == "1010"
        instance.name.should == "Dr Jack Dorsey"
      end
    end

    context "with a string argument" do
      it "calls parse_track! with the string argument" do
        arg = "foo=bar"
        @instance.should_receive(:parse_track!).with(arg)
        @instance.send :initialize, arg
      end
    end
  end

  describe "#update!" do
    context "with no arguments" do
      it "calls update! with an empty hash" do
        @instance.should_not_receive(:send)
        @instance.update!
      end
    end

    context "with a nil argument" do
      it "raises an exception" do
        lambda { @instance.update! nil }.should raise_error(NoMethodError)
      end
    end

    context "with a hash argument" do
      it "assigns the passed keys" do
        arg = {:pan => "bar"}
        @instance.update! arg
        @instance.pan.should == "bar"
      end

      it "ignores parameters that do not correspond to a setter" do
        @instance.should_not respond_to(:foo=)
        expect { @instance.update! :foo => 97 }.to_not raise_error
      end
    end
    
    context "with a subclass of hash" do
      before do
        @other_hash = OtherHash.new
        @other_hash[:pan] = "bar"
        @other_hash.should be_kind_of(Hash)
      end

      it "assigns the passed keys" do
        @instance.update! @other_hash
        @instance.pan.should == "bar"
      end
    end
  end

  describe "#name" do
    it "returns a string" do
      @instance.name.should be_instance_of(String)
    end

    [
      ["Prince", nil, nil, "Prince"],
      ["Walters", "Cameron", nil, "Cameron Walters"],
      ["Howser", "Doogie", "Dr", "Dr Doogie Howser"],
    ].each do |surname, given_name, title, name|
      it "returns #{name} for the given input" do
        @instance.surname = surname
        @instance.given_name = given_name
        @instance.title = title
        @instance.name.should == name
      end
    end
  end

  describe "#expiration=" do
    [
      ["YYMM", 0,  0],
      ["0000", 0,  0],
      ["9901", 99, 1],
      ["1312", 13, 12],
    ].each do |expiration, year, month|
      it "parses the expiration '#{expiration}' into year (#{year}) and month (#{month}) integers" do
          @instance.expiration = expiration
          @instance.expiration_year.should == year
          @instance.expiration_month.should == month
      end
    end
  end

  describe "#valid?" do
    before do
      @plastic = Plastic.new(:pan => "SOME PAN", :expiration => "SOME EXPIRATION")
    end

    it "is valid if it has both a pan and an expiration" do
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
  end
end
