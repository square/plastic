require File.dirname(__FILE__) + '/../spec_helper'

describe Plastic do
  before :each do
    @instance = described_class.new
  end

  [
    :pan, :expiration,
    :track_name, :surname, :given_name, :title,
    :service_code, :cvv2,
    :track_1, :track_2,
  ].each do |var|
    it "has accessor :#{var} and :#{var}=" do
      @instance.should respond_to(:"#{var}")
      @instance.should respond_to(:"#{var}=")
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
        arg = {:foo => "bar"}
        @instance.should_receive(:foo=).with("bar")
        @instance.update! arg
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
end
