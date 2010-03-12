class Plastic
  def valid_expiration_month?
    (1..12).include?(expiration_month.to_i)
  end
end