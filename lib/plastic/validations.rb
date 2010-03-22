require 'date'

class Plastic
  def valid_pan?
    valid_pan_length? && valid_pan_checksum?
  end

  def valid_expiration?
    return false unless valid_expiration_year? && valid_expiration_month?
    this = Time.now.utc
    if this.year == expiration_datetime_year
      (this.month..12).include?(expiration_month)
    elsif expiration_datetime_year > this.year
      true
    else
      false
    end
  end

private

  def valid_pan_length?
    pan.to_s.length >= 12
  end

  def valid_pan_checksum?
    odd = false
    sum = pan.reverse.chars.inject(0) do |checksum, d|
      d = d.to_i
      checksum + ((odd = !odd) ? d : (d * 2 > 9 ? d * 2 - 9 : d * 2))
    end
    sum % 10 == 0
  end

  def valid_expiration_month?
    (1..12).include?(expiration_month.to_i)
  end

  def valid_expiration_year?
    this = Time.now.utc
    (this.year..this.year + 20).include?(expiration_datetime_year)
  end

  def expiration_datetime_year
    DateTime.strptime(expiration_year.to_s, "%y").year
  end

end
