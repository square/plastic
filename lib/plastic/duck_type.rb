class Plastic

  # ActiveMerchant::Billing::CreditCard
  def number
    pan
  end

  def year
    expiration.to_s[0..1]
  end

  def month
    expiration.to_s[2..3]
  end

  def verification_value
    cvv2
  end

  def track1
    track_1
  end

  def track2
    track_2
  end
end
