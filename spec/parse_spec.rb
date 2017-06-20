require 'spec_helper'
require 'phonefu'

describe Phonefu do
  def self.expect_number input, assume_country, expected_country, expected_digits, mob
    it "returns #{expected_digits.inspect} in #{expected_country.inspect} for #{input.inspect} assuming country #{assume_country.inspect}" do
      tn = Phonefu.parse input, assume_country
      if expected_country
        expect(tn.country.iso2).to eq expected_country
        expect(tn.format nil).to eq expected_digits
        expect(tn.mobile?).to(mob ? be_truthy : be_falsy)
      else
        expect(tn.country).to be_nil
      end
    end
  end

  describe 'normalise' do
    expect_number "(33) 4 66 92 01 99", "49" , "FR", "04 66 92 01 99", false
    expect_number "(33) 6 76 99 07 59", nil  , "FR", "06 76 99 07 59", true
    expect_number "+33466920199",       nil  , "FR", "04 66 92 01 99", false
    expect_number "(262) 99.42.00",     nil  , nil , "(262) 99.42.00", false
    expect_number "(1) 508 349 6820",   nil  , nil , "+15083496820"  , false
    expect_number "+33 6 77 88 99 00",  nil  , "FR", "06 77 88 99 00", true
    expect_number "+32.473.36.50.21",   nil  , "BE", "0473 36 50 21" , true
    expect_number "0652520059",         "33" , "FR", "06 52 52 00 59", true
    expect_number "06 85 30 18 36",     "33" , "FR", "06 85 30 18 36", true
    expect_number "06-23-88-51-11",     "33" , "FR", "06 23 88 51 11", true
    expect_number "09/16/22/33/44",     "33" , "FR", "09 16 22 33 44", false
    expect_number "+44 7564111999",     "33" , "UK", "0756 411 1999" , true
    expect_number "0156 4111 999",      "44" , "UK", "0156 411 1999" , false
    expect_number "+1 917 214 1234",    nil  , nil , "+19172141234"  , false
    expect_number "(49) 9133767589",    "33" , "DE", "0913 376 7589" , false
    expect_number "030 3376 7589",      "49" , "DE", "030 3376 7589" , false
    expect_number "015 3376 7589",      "49" , "DE", "0153 3767589"  , true
    expect_number "(49) 33 203 679 952", "353", "DE", "033203 67 9952", false
    # expect_number "( 32) 85 23 57 99",   "+3285235799"
    # expect_number "(0041) 79 209 26 99", "+41792092699"
    # expect_number " 06 92 87 94 99    ", "+33692879499"
    # expect_number "(0590) 841444",       "+33590841444"
    # expect_number "00617-420999185",     "+617420999185"
    # expect_number "0687964650  ET 0143583599", nil
    # expect_number "06141111110/0760754726",    nil
    # expect_number "() 05 037 70 38",           nil
    # expect_number "Non encore connu",          nil
    # expect_number "",                          nil
    # expect_number "   ",                       nil
    # expect_number nil,                         nil
  end
end
