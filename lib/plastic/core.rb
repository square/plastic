class Plastic
  attr_accessor :pan, :expiration
  attr_accessor :track_name, :surname, :given_name, :title
  attr_accessor :service_code, :cvv2
  attr_accessor :track_1, :track_2

  def initialize(attributes={})
    if attributes.instance_of? Hash
      self.update! attributes
      parse_tracks!
    else
      parse_track! attributes
    end
  end

  def update!(attributes={})
    attributes.each do |key, value|
      setter_method_name = :"#{key}="
      send(setter_method_name, value) if respond_to?(setter_method_name)
    end
  end

  def name
    [title, given_name, surname].flatten.compact.join(" ").strip
  end

  def valid?
    value_is_present?(pan) && value_is_present?(expiration)
  end

  private

  def value_is_present?(value)
    !value_is_blank?(value)
  end

  def value_is_blank?(value)
    if value.respond_to?(:blank?)
      value.blank?
    elsif value.respond_to?(:empty?)
      value.empty?
    else
      value.nil?
    end
  end
end
