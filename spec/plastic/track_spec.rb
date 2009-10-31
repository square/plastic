require File.dirname(__FILE__) + '/../spec_helper'

describe Plastic do
  before :each do
    @instance = described_class.new
  end

  describe "#parse_tracks!" do
    it "calls #parse_track_2, then #parse_track_1" do
      class FakeError < StandardError; end
      @instance.should_receive(:parse_track_2!).with().once
      @instance.should_receive(:parse_track_1!).with().once.and_raise(FakeError)
      lambda { @instance.parse_tracks! }.should raise_error(FakeError)
    end
  end
end
