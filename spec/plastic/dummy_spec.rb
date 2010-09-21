require 'spec_helper'

describe Plastic::Dummy do
  subject { Plastic::Dummy }
  
  it "produces valid cnp_attributes" do
    Plastic.new(subject.cnp_attributes).should be_valid
  end
  
  it "produces valid track_1_attributes" do
    Plastic.new(subject.track_1_attributes).should be_valid
  end
  
  it "produces valid track_2_attributes" do
    Plastic.new(subject.track_2_attributes).should be_valid
  end
end
