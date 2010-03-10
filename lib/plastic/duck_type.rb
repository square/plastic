class Plastic
  # ActiveMerchant::Billing::CreditCard
  [
    [:number, :pan],
    [:first_name, :given_name],
    [:last_name, :surname],
    [:verification_value, :cvv2],
    [:verification_value?, :cvv2],
    [:track1, :track_1],
    [:track2, :track_2],
  ].each do |_alias, method|
    alias_method _alias, method
  end

  def year
    expiration.to_s[0..1]
  end

  def month
    expiration.to_s[2..3]
  end
end
