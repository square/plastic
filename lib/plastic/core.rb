class Plastic
  attr_accessor :pan, :expiration, :name, :cvv2
  attr_accessor :track_1, :track_2

  def initialize(attributes={})
    if attributes.instance_of? Hash
      self.update! attributes
    else
      parse_track! attributes
    end
  end

  def update!(attributes={})
    attributes.each do |key, value|
      send :"#{key}=", value
    end
  end
end
