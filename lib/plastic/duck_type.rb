class Plastic
  # ActiveMerchant::Billing::CreditCard
  DUCK_TYPE_INTERFACE = [
    [:number, :pan],
    [:first_name, :given_name],
    [:last_name, :surname],
    [:verification_value, :cvv2],
    [:security_code, :cvv2],
    [:expiration_date, :expiration],
    [:track1, :track_1],
    [:track2, :track_2],
  ]

  DUCK_TYPE_INTERFACE.each do |_alias, attribute_name|
    alias_method _alias, attribute_name
    alias_method :"#{_alias}=", :"#{attribute_name}="
    define_method :"#{_alias}?", lambda { value_is_present?(send(_alias)) }
  end

  def year
    expiration ? DateTime.new(expiration_year).strftime("%y") : nil
  end

  def month
    expiration ? "%02d" % expiration_month : nil
  end
end
