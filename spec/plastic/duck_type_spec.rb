require File.dirname(__FILE__) + '/../spec_helper'

describe Plastic do
  before :each do
    @instance = described_class.new
  end

  Plastic::DUCK_TYPE_INTERFACE.each do |_alias, method|
    it "##{method} is aliased as ##{_alias}" do
      @instance.method(_alias).should == @instance.method(method)
    end

    it "##{method} is aliased as ##{_alias}" do
      @instance.method("#{_alias}=").should == @instance.method("#{method}=")
    end

    it "##{method}? checks blankness of ##{_alias}" do
      @instance.send(:"#{_alias}?").should be_false
    end
  end

  # TODO: spec #year
  # TODO: spec #month
end
