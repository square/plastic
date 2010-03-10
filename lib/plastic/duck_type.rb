class Plastic
  # ActiveMerchant::Billing::CreditCard
  [
    [:number, :pan],
    [:first_name, :given_name],
    [:last_name, :surname],
    [:verification_value, :cvv2],
    [:track1, :track_1],
    [:track2, :track_2],
  ].each do |_alias, method|
    alias_method _alias, method
    define_method :"#{_alias}?", lambda { !value_is_blank?(send(_alias)) }
  end

  def year
    expiration.to_s[0..1]
  end

  def month
    expiration.to_s[2..3]
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
