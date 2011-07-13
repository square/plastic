require 'rubygems'

$:.unshift(File.join(File.dirname(__FILE__), %w[.. lib]))

require 'plastic'
require 'plastic/dummy'
require 'spec/expectations'

def freeze_time!(new_time = Time.now)
  Time.stub!(:now).and_return(new_time)
end
