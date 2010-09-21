module Plastic::Dummy
  def pan
    "4111111111111111"
  end

  def expiration_date
    date = Date.today + 90 #days
    date.strftime("%y%m")
  end

  def card_verification_code
    "123"
  end
  
  def track_2
    "#{pan}=#{expiration_date}#{card_verification_code}"
  end

  def service_code
    "321"
  end
  
  def cardholder_name_and_title
    "Name/Cardholder.Mr"
  end
  
  def track_1
    "B#{pan}^#{cardholder_name_and_title}^#{expiration_date}#{service_code}"
  end
  
  def cnp_attributes
    {
      :pan => pan,
      :expiration_date => expiration_date,
      :card_verification_code => card_verification_code,
    }
  end
  
  def track_2_attributes
    { :track_2 => track_2 }
  end

  def track_1_attributes
    { :track_1 => track_1 }
  end
  
  extend self
end