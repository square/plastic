class Plastic
  attr_accessor :pan, :expiration, :surname, :given_name, :title, :cvv2
  attr_accessor :track_1, :track_2, :track_name

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

  def name
    [title, given_name, surname].flatten.compact.join(" ").strip
  end
end
