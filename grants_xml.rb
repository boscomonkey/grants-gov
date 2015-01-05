#!/usr/bin/env ruby

#
# grants_xml.rb
#

require 'nokogiri'

class GrantsXml

  def initialize(xml_fname)
    File.open(xml_fname) {|f| @doc = Nokogiri::XML(f) }
  end

end


if __FILE__ == $0
  require 'minitest/autorun'

  class GrantsXmlTest < Minitest::Test
    def setup
      raise "USAGE: #{$0} XML_FILE" unless ARGV[0]
      xml_fname = ARGV[0]

      @@grants ||= GrantsXml.new(xml_fname)
    end

    def grants
      @@grants
    end

    def test_initialize
      assert_equal true, grants != nil
    end
  end

end
