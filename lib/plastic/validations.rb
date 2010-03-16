require 'date'

class Plastic
  def valid_expiration_month?
    (1..12).include?(expiration_month.to_i)
  end

  def valid_expiration_year?
    this = Time.now.utc
    (this.year..this.year + 20).include?(DateTime.strptime(expiration_year.to_s, "%y").year)
  end
end
