class Plastic
  BRANDS = [:visa, :mastercard, :american_express, :discover, :discover_diners, :jcb, :unionpay]

  attr_accessor :pan, :expiration, :masked_pan
  attr_accessor :track_name, :surname, :given_name, :title
  attr_accessor :service_code, :cvv2
  attr_accessor :track_1, :track_2

  def initialize(attributes={})
    if attributes.kind_of? Hash
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

  def expiration=(yymm)
    @expiration = yymm.to_s[0..3]
  end

  def expiration_year
    DateTime.strptime(expiration_yy, "%y").year
  end

  def expiration_month
    expiration_mm.to_i
  end

  def masked_pan
    return @masked_pan unless @masked_pan.nil?
    return nil if pan.nil? || pan.length < 12
    @masked_pan ||= pan[0...6] + "X" * pan[6...-4].size + pan[-4..-1]
  end

  def brand
    case (masked_pan || "").gsub('X', '0')
    when /^4\d{15}$/        then :visa
    when /^5[1-5]\d{14}$/   then :mastercard
    when /^677189\d{10}$/   then :mastercard
    when /^6011\d{12}$/     then :discover
    when /^64[4-9]\d{13}$/  then :discover
    when /^65\d{14}$/       then :discover
    when /^62\d{14}$/       then :unionpay
    when /^3[47]\d{13}$/    then :american_express
    when /^352[8-9]\d{12}$/ then :jcb
    when /^35[3-8]\d{13}$/  then :jcb
    when /^30\d{12}$/       then :discover_diners
    when /^36\d{12}$/       then :discover_diners
    when /^38\d{12}$/       then :discover_diners
    when /^39\d{12}$/       then :discover_diners
    end
  end

private

  def expiration_yy
    @expiration.to_s[0..1]
  end

  def expiration_mm
    @expiration.to_s[2..3]
  end

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
