# http://en.wikipedia.org/wiki/Magnetic_stripe

class Plastic
  def parse_tracks!
    parse_track_2!
    parse_track_1!
  end

  def parse_track!(value)
    parse_track_2! value
    parse_track_1! value
  end

  # Track 1, Format B
  #
  # Start sentinel — one character ('%')
  # Format code="B" — one character (alpha only)
  # Primary account number (PAN) — up to 19 characters. Usually, but not always, matches the credit card number printed on the front of the card.
  # Field Separator — one character ('^')
  # Country Code - 3 characters (exists only if PAN starts with '59')
  # Name — two to 26 characters
  # Field Separator — one character ('^')
  # Expiration date — four characters in the form YYMM.
  # Service code — three characters or a field separator ('^') if the service code does not exist
  # Discretionary data — may include Pin Verification Key Indicator (PVKI, 1 character), PIN Verification Value (PVV, 4 characters), Card Verification Value or Card Verification Code (CVV or CVK, 3 characters)
  # End sentinel — one character ('?')

  TRACK_1_PARSER = /
    \A                                      # Start of string
    %?                                      # Start sentinel
    [bB]                                    # Format code
    (\d{12,19}|\d{4}\s\d{6}\s\d{5})         # PAN
    \^                                      # Field separator
    (                                       # Name field
      (\d{3})?                              # Country code
      (?=[^^]{2,26})                        # Lookahead assertion
      ([^\/]+)                              # Surname
      (?:\/?([^.]+)(?:\.?([^^]+))?)?        # Given name and title
    )                                       #
    \^                                      # Field separator
    (\d{4})                                 # Expiration
    (\d{3}|\^)                              # Service code
    ([^?]*)                                 # Discretionary data
    \??                                     # End sentinel
    \z                                      # End of string
  /x.freeze

  def self.track_1_parser
    TRACK_1_PARSER
  end

  def parse_track_1!(value=nil)
    value ||= track_1
    if matched = self.class.track_1_parser.match(value.to_s)
      self.pan = matched[1].delete(' ')
      self.track_name = matched[2]
      self.surname = matched[4]
      self.given_name = matched[5]
      self.title = matched[6]
      self.expiration = matched[7]
      self.service_code = matched[8]
    end
  end

  # Track 2
  #
  # Start sentinel — one character (generally ';')
  # Primary account number (PAN) — up to 19 characters. Usually, but not always, matches the credit card number printed on the front of the card.
  # Separator — one char (generally '=')
  # Expiration date — four characters in the form YYMM.
  # Service code — three characters
  # Discretionary data — as in track one
  # End sentinel — one character (generally '?')

  TRACK_2_PARSER = /\A;?(\d{12,19})\=([^\?]*)\??\z/.freeze
  TRACK_2_NON_REGISTERED_PARSER = /(\d{3})(\d{4})(.{3}|\=)([^\?]*)\??\z/.freeze
  TRACK_2_REGISTERED_PARSER = /(\d{4})(.{3}|\=)([^\?]*)\??\z/.freeze

  def self.track_2_parser
    TRACK_2_PARSER
  end

  def self.track_2_non_registered_parser
    TRACK_2_NON_REGISTERED_PARSER
  end

  def self.track_2_registered_parser
    TRACK_2_REGISTERED_PARSER
  end

  def parse_track_2!(value=nil)
    value ||= track_2
    if matched = self.class.track_2_parser.match(value.to_s)
      self.pan = matched[1]
      if is_non_registered_iso_card
        matched = self.class.track_2_non_registered_parser.match(matched[2])
        self.expiration = matched[2]
        self.service_code = matched[3]
      else
        matched = self.class.track_2_registered_parser.match(matched[2])
        self.expiration = matched[1]
        self.service_code = matched[2]
      end
    end
  end

protected

  def is_non_registered_iso_card
    return self.pan =~ /\A59.*\z/
  end
end
