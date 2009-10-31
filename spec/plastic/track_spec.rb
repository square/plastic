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

  describe "#track_1_parser" do
    it "returns a regular expression" do
      @instance.track_1_parser.should be_instance_of(Regexp)
    end
  end

  describe "#parse_track_1!" do
    def mock_track_1_parser
      parser = mock()
      @instance.should_receive(:track_1_parser).once.and_return(parser)
      parser
    end

    context "with no arguments" do
      it "parses the contents of #track_1" do
        arg = "foo"
        @instance.should_receive(:track_1).once.and_return(arg)
        mock_track_1_parser.should_receive(:match).with(arg).once
        @instance.parse_track_1!
      end
    end
  end
end
