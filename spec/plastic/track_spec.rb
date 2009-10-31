require File.dirname(__FILE__) + '/../spec_helper'

describe Plastic do
  before :each do
    @instance = described_class.new
  end

  describe "#parse_tracks!" do
    it "calls #parse_track_2, then #parse_track_1" do
      @instance.should_receive(:parse_track_2!).with().once
      @instance.should_receive(:parse_track_1!).with().once.and_raise(StandardError)
      lambda { @instance.parse_tracks! }.should raise_error(StandardError)
    end
  end

  describe "#parse_track!" do
    it "calls #parse_track_2, then #parse_track_1" do
      arg = "foo"
      @instance.should_receive(:parse_track_2!).with(arg).once
      @instance.should_receive(:parse_track_1!).with(arg).once.and_raise(StandardError)
      lambda { @instance.parse_track! arg }.should raise_error(StandardError)
    end
  end
end
