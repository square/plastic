require 'date'

class Plastic
  PIVOT_YEAR = 20.freeze

  def valid?
    errors.clear
    valid_pan?
    valid_brand?
    valid_expiration?
    errors.empty?
  end

  def errors
    @errors ||= []
  end

  def valid_brand?
    valid = value_is_present?(brand)
    errors << "Unknown card brand" unless valid
    valid
  end

  def valid_pan?
    unless value_is_present?(pan)
      errors << "PAN not present"
      return false
    end
    valid_pan_characters? && valid_pan_length? && valid_pan_checksum?
  end

  def valid_expiration?
    unless value_is_present?(expiration) && expiration != '='
      errors << "Expiration not present"
      return false
    end
    return false unless valid_expiration_year? && valid_expiration_month?

    # We subtract 13 hours from the current expiration time in UTC
    # so that a card that expires on 28 February 2013 in UTC-1300 is still considered valid
    # until 13:00 1 March 2013 in UTC.
    this = Time.now.utc - (60 * 60 * 13)

    if this.year == expiration_year
      valid = (this.month..12).include?(expiration_month)
      errors << "Card has expired" unless valid
      valid
    elsif expiration_year > this.year && expiration_year < this.year + PIVOT_YEAR
      true
    else
      errors << "Card has expired"
      false
    end
  end

private

  def valid_pan_characters?
    valid = pan.to_s =~ /\A[\d ]+\z/
    errors << "PAN contains non-digit characters" unless valid
    valid
  end

  def valid_pan_length?
    valid = (pan.to_s.length >= 12)
    errors << "PAN is too short" unless valid
    valid
  end

  def valid_pan_checksum?
    odd = false
    sum = pan.reverse.chars.inject(0) do |checksum, d|
      d = d.to_i
      checksum + ((odd = !odd) ? d : (d * 2 > 9 ? d * 2 - 9 : d * 2))
    end

    valid = (sum % 10 == 0)
    errors << "PAN does not pass checksum" unless valid
    valid
  end

  def valid_expiration_month?
    valid = (1..12).include?(expiration_month)
    errors << "Invalid expiration month" unless valid
    valid
  end

  def valid_expiration_year?
    valid = (expiration_yy =~ /\d\d/)
    errors << "Invalid expiration year" unless valid
    valid
  end
end
