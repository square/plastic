require File.dirname(__FILE__) + '/../spec_helper'

describe Plastic do
  subject { described_class.new }

  describe "#parse_tracks!" do
    it "calls #parse_track_2, then #parse_track_1" do
      subject.should_receive(:parse_track_2!).with().once
      subject.should_receive(:parse_track_1!).with().once.and_raise(StandardError)
      expect { subject.parse_tracks! }.to raise_error(StandardError)
    end
  end

  describe "#parse_track!" do
    it "calls #parse_track_2, then #parse_track_1" do
      arg = "foo"
      subject.should_receive(:parse_track_2!).with(arg).once
      subject.should_receive(:parse_track_1!).with(arg).once.and_raise(StandardError)
      expect { subject.parse_track! arg }.to raise_error(StandardError)
    end
  end

  describe "self.track_1_parser" do
    it "returns a regular expression" do
      described_class.track_1_parser.should be_instance_of(Regexp)
    end
  end

  describe "#parse_track_1!" do
    def mock_track_1_parser
      subject
      parser = mock()
      described_class.should_receive(:track_1_parser).once.and_return(parser)
      parser
    end

    it "with no arguments parses the contents of #track_1" do
      arg = "foo"
      subject.should_receive(:track_1).once.and_return(arg)
      mock_track_1_parser.should_receive(:match).with(arg).once
      subject.parse_track_1!
    end

    it "with nil parses the contents of #track_1" do
      arg = "foo"
      subject.should_receive(:track_1).once.and_return(arg)
      mock_track_1_parser.should_receive(:match).with(arg).once
      subject.parse_track_1! nil
    end

    [0, 1, "foo", "bar", StandardError].each do |value|
      it "with #{value} attempts to parse the string representation" do
        mock_track_1_parser.should_receive(:match).with(value.to_s).once
        subject.parse_track_1! value
      end
    end
  end

  describe "self.track_2_parser" do
    it "returns a regular expression" do
      described_class.track_2_parser.should be_instance_of(Regexp)
    end
  end

  describe "#parse_track_2!" do
    def mock_track_2_parser
      subject
      parser = mock()
      described_class.should_receive(:track_2_parser).once.and_return(parser)
      parser
    end

    it "with no arguments parses the contents of #track_2" do
      arg = "foo"
      subject.should_receive(:track_2).once.and_return(arg)
      mock_track_2_parser.should_receive(:match).with(arg).once
      subject.parse_track_2!
    end

    it "with nil parses the contents of #track_2" do
      arg = "foo"
      subject.should_receive(:track_2).once.and_return(arg)
      mock_track_2_parser.should_receive(:match).with(arg).once
      subject.parse_track_2! nil
    end

    [0, 1, "foo", "bar", StandardError].each do |value|
      it "with #{value} attempts to parse the string representation" do
        mock_track_2_parser.should_receive(:match).with(value.to_s).once
        subject.parse_track_2! value
      end
    end
  end

  [
    # Track 1
    ["", nil, nil, ""],
    ["foobar", nil, nil, ""],
    ["B1^N^1230", nil, nil, ""],
    ["%B1^N^1230?", nil, nil, ""],
    ["B12345678901234567890^CW^1010123", nil, nil, ""],
    ["B123456789012^CW^0909123", "123456789012", "0909", "CW", "123"],
    ["B123456789012345^Dorsey/Jack^1010123", "123456789012345", "1010", "Jack Dorsey", "123"],
    ["%B123456789012345^Dorsey/Jack^1010123?", "123456789012345", "1010", "Jack Dorsey", "123"],
    ["B123456789012345^Dorsey/Jack.Dr^1010123", "123456789012345", "1010", "Dr Jack Dorsey", "123"],
    ["%B123456789012345^Dorsey/Jack.Dr^1010123?", "123456789012345", "1010", "Dr Jack Dorsey", "123"],
    ["%B123456789012345^Dorsey/Jack.Dr^1010^123?", "123456789012345", "1010", "Dr Jack Dorsey", "^"],
    ["%B1234 567890 12345^Dorsey/Jack.Dr^1010123?", "123456789012345", "1010", "Dr Jack Dorsey", "123"],
    ["%B593456789012345^101Dorsey/Jack.Dr^1010123?", "593456789012345", "1010", "Dr Jack Dorsey", "123"],
    ["%B593456789012345^101Dorsey/Jack.Dr^1010^123?", "593456789012345", "1010", "Dr Jack Dorsey", "^"],

    # Track 2
    ["", nil, nil, "", nil],
    ["foobar", nil, nil, "", nil],
    ["1=1230", nil, nil, "", nil],
    ["?1=1230?", nil, nil, "", nil],
    [";123456789012345=1010?123?", nil, nil, "", nil],  # terminator in the middle of discretionary data
    ["12345678901234567890=1010123", nil, nil, "", nil],
    ["123456789012=", "123456789012", nil, "", nil], # nothing matched past the pan (should be invalid)
    ["123456789012=1", "123456789012", nil, "", nil], # nothing matched past the pan (should be invalid)
    ["123456789012=0909123", "123456789012", "0909", "", "123"],
    ["123456789012==123", "123456789012", "=", "", "123"], # missing expiration date
    ["123456789012=0909=", "123456789012", "0909", "", "="], # missing service code
    ["123456789012345=1010123", "123456789012345", "1010", "", "123"],
    [";123456789012345=1010123?", "123456789012345", "1010", "", "123"],
    [";593456789012345=1?", "593456789012345", nil, "", nil], # nothing matched past pan (should be invalid)
    [";593456789012345=?", "593456789012345", nil, "", nil], # nothing matched past pan (should be invalid)
    [";593456789012345=321=123?", "593456789012345", "=", "", "123"], # missing expiration date
    [";593456789012345=3211010=?", "593456789012345", "1010", "", "="], # missing service code
    [";593456789012345=3211010123?", "593456789012345", "1010", "", "123"],
    ["123456789012345=1010=23", "123456789012345", "1010", "", "="],
  ].each do |value, pan, expiration, name, service_code|
    it "#parse_track!(\"#{value}\") correctly parses the track data" do
      subject.parse_track! value
      subject.pan.should == pan
      subject.expiration.should == expiration
      subject.name.should == name
      subject.service_code.should == service_code
    end
  end
end
