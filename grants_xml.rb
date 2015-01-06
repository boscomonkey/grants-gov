#!/usr/bin/env ruby

#
# grants_xml.rb
#

require 'nokogiri'

=begin

doc -> Nokogiri::XML::Document
  synopsis -> Nokogiri::XML::NodeSet	doc.xpath('FundingOppSynopsis')
    first -> Nokogiri::XML::Element	synopsis[0]
      txt -> Nokogiri::XML::Text	first.children[0]
      elt  -> Nokogiri::XML::Element	first.children[1]
        "PostDate"	elt.node_name
        "01302008"	elt.text

=end
class GrantsXml

  def initialize(xml_fname)
    File.open(xml_fname) {|f| @doc = Nokogiri::XML(f) }
  end

  def synopses
    @doc.xpath('//FundingOppSynopsis')
  end

  def synopsis(nth)
    synopses[nth]
  end

  def synopsis_elements(nth)
    syn = synopsis(nth)
    syn.children.select {|node| node.class == Nokogiri::XML::Element}
  end

end

if __FILE__ == $0
  require 'minitest/autorun'

  class GrantsXmlTest < Minitest::Test
    def get_grants
      @@grants ||= GrantsXml.new('GrantsDBExtract20150105.xml')
    end

    def get_synopses
      @@synopses = get_grants.synopses
    end

    def test_initialize
      refute_nil get_grants
    end

    def test_synopses
      assert_equal 19211, get_synopses.size
    end

    def test_first_synopsis
      syn = get_grants.synopsis(0)
      assert_instance_of Nokogiri::XML::Element, syn
      assert_equal 57, syn.children.size
    end

    def test_first_synopsis_nodenames
      elts = get_grants.synopsis_elements(0)
      nodenames = elts.collect {|elt| elt.node_name}
      assert_equal ["PostDate", "UserID", "Password", "FundingInstrumentType", "FundingActivityCategory", "FundingActivityCategory", "FundingActivityCategory", "OtherCategoryExplanation", "NumberOfAwards", "EstimatedFunding", "AwardCeiling", "AwardFloor", "AgencyMailingAddress", "FundingOppTitle", "FundingOppNumber", "ApplicationsDueDate", "ApplicationsDueDateExplanation", "ArchiveDate", "Location", "Office", "Agency", "FundingOppDescription", "CFDANumber", "EligibilityCategory", "AdditionalEligibilityInfo", "CostSharing", "ObtainFundingOppText", "AgencyContact"], nodenames
    end
  end

end
