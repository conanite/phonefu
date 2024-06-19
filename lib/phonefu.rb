require "phonefu/version"

module Phonefu
  INITIAL_ZERO = /^0/.freeze
  INITIAL_PLUS = /^\+/.freeze
  def self.parse number, default_country_code=nil
    digits = number || ""
    digits = number.gsub(/[^\d]/, '') # brutally discard any non-digit
    digits = digits.gsub(/^00/, '')   # replace initial 00 with nothing
    if digits.match INITIAL_ZERO
      TelephoneNumber.new(default_country_code, digits.gsub(INITIAL_ZERO, ''))
    else
      country = Country.detect digits
      if country
        TelephoneNumber.new(country, digits.gsub(country.belongs, ''))
      else
        TelephoneNumber.new(nil, number)
      end
    end
  end

  class TelephoneNumber
    attr_accessor :country_code, :number, :country

    def initialize country_or_code, number
      @number = number
      if country_or_code.is_a?(String)
        @country_code = country_or_code
        @country = Country.find(country_code)
      elsif country_or_code
        @country = country_or_code
        @country_code = country.dial_code
      end
    end

    def mobile?
      country && country.mobile?(number)
    end

    def format with_cc=false
      country ? country.format(number, with_cc) : number
    end

    def to_sms
      "#{country_code}#{number}" if mobile?
    end

    def to_s
      country_code ? "+#{country_code}#{number}" : number
    end
  end

  module Country
    @@countries_by_dial_code = { }
    def self.register  country ; @@countries_by_dial_code[country.dial_code] = country ; end
    def self.find country_code ; @@countries_by_dial_code[country_code]                ; end
    def self.detect     digits
      @@countries_by_dial_code.values.detect { |c| c.belongs? digits }
    end

    class Country
      attr_accessor :iso2, :dial_code, :mobile_regex, :belongs, :formatters
      def initialize iso2, dial_code, mobile_regex, formatters=nil
        @iso2, @dial_code, @mobile_regex = iso2, dial_code, mobile_regex.freeze
        @formatters = formatters || { }
        @belongs = /^#{dial_code}/.freeze
      end

      def belongs? num
        num.match @belongs
      end

      def mobile? num
        @mobile_regex && num.match(@mobile_regex)
      end

      def prepend_cc num, with_cc
        if with_cc
          if with_cc == true
            "+#{dial_code} #{num}"
          else
            prepend_cc num, with_cc.to_s.downcase != iso2.downcase
          end
        else
          "0#{num}"
        end
      end

      def format num, with_cc
        formatters.each do |regex, pattern|
          if matchdata = num.match(regex)
            f = num.gsub(regex, pattern)
            return prepend_cc f, with_cc
          end
        end
        return prepend_cc num, with_cc
      end

      def to_s
        "#{iso2}(#{dial_code})"
      end

      alias inspect to_s
    end

    NO_COUNTRY = Country.new "", "", nil
    register Country.new("GR" , "30" , nil)
    register Country.new("NL" , "31" , /^6\d{8}$/, { /^(\d)(\d\d)(\d\d)(\d\d)(\d\d)$/ => '\1 \2 \3 \4 \5' })
    register Country.new("BE" , "32" , /^4(6|7|8|9)\d{7}$/,
                         { /^(4(6|7|8|9)\d)(\d\d)(\d\d)(\d\d)$/ => '\1 \3 \4 \5',
                           /^(1|2|3|4)(\d\d\d)(\d\d)(\d\d)$/ => '\1 \2 \3 \4',
                           /^(\d\d)(\d\d)(\d\d)(\d\d)$/ => '\1 \2 \3 \4' })
    register Country.new("FR" , "33" , /^[67]\d{8}$/, { /^(\d)(\d\d)(\d\d)(\d\d)(\d\d)$/ => '\1 \2 \3 \4 \5' })
    register Country.new("ES" , "34" , nil)
    register Country.new("GI" , "350", nil)
    register Country.new("PT" , "351", nil)
    register Country.new("LU" , "352", nil)
    register Country.new("IE" , "353", /^8/, {
                           /^1(\d{3})(\d+)$/ => '1 \1 \2',
                           /^(\d{2})(\d{3})(\d+)$/ => '\1 \2 \3',
                         })
    register Country.new("IS" , "354", nil)
    register Country.new("AL" , "355", nil)
    register Country.new("MT" , "356", nil)
    register Country.new("CY" , "357", nil)
    register Country.new("FI" , "358", nil)
    register Country.new("BG" , "359", nil)
    register Country.new("HU" , "36" , nil)
    register Country.new("LT" , "370", nil)
    register Country.new("LV" , "371", nil)
    register Country.new("EE" , "372", nil)
    register Country.new("MD" , "373", nil)
    register Country.new("AM" , "374", nil)
    register Country.new("BY" , "375", nil)
    register Country.new("AD" , "376", nil)
    register Country.new("MC" , "377", nil)
    register Country.new("SM" , "378", nil)
    register Country.new("VA" , "379", nil)
    register Country.new("UA" , "380", nil)
    register Country.new("RS" , "381", nil)
    register Country.new("ME" , "382", nil)
    register Country.new("XKX", "383", nil)
    register Country.new("HR" , "385", nil)
    register Country.new("SI" , "386", nil)
    register Country.new("BA" , "387", nil)
    register Country.new("EU" , "388", nil)
    register Country.new("MK" , "389", nil)
    register Country.new("IT" , "39" , nil)
    register Country.new("RO" , "40" , nil)
    register Country.new("CH" , "41" , nil)
    register Country.new("AT" , "43" , nil)
    register Country.new("UK" , "44" , /^7[1-9]\d{8}$/, {
                           /^(2\d)(\d{4})(\d{4})$/ => '\1 \2 \3',
                           /^(\d\d\d)(\d{3})(\d{4})$/ => '\1 \2 \3',
                         })
    register Country.new("DK" , "45" , nil)
    register Country.new("SE" , "46" , nil)
    register Country.new("NO" , "47" , nil)
    register Country.new("PL" , "48" , nil)
    register Country.new("DE" , "49" , /^1(5|6|7)/, {
                           /^(30|40|69|89)(\d{4})(\d{4})$/ => '\1 \2 \3',
                           /^(3\d{4})(\d{2})(\d+)$/ => '\1 \2 \3',
                           /^1(5|6|7)(\d)(\d+)$/ => '1\1\2 \3',
                           /^(\d{3})(\d+)(\d{4})$/ => '\1 \2 \3' })
  end
end
