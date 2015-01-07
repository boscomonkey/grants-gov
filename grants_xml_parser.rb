#!/usr/bin/env ruby

#
# grants_xml.rb
#

require 'nokogiri'

=begin

doc -> Nokogiri::XML::Document
  synopses -> Nokogiri::XML::NodeSet	doc.xpath('FundingOppSynopsis')
    synopsis -> Nokogiri::XML::Element	synopses[0]
      txt -> Nokogiri::XML::Text	synopsis.children[0]
      elt  -> Nokogiri::XML::Element	synopsis.children[1]
        "PostDate"	elt.node_name
        "01302008"	elt.text

EXAMPLE USAGE:

parser = GrantsXmlParser.new('example.xml')
synopses = parser.funding_opportunity_synopses		# NodeSet
synopsis = synopses[0]
duples = GrantsXmlParser.synopsis_node_value_pairs(synopsis)
names = GrantsXmlParser.synopsis_nodenames(synopsis)

=end
class GrantsXmlParser

  class << self
    # Return array of XML::Element nodes (ignoring Text nodes)
    def synopsis_elements(syn)
      syn.children.select {|node| node.class == Nokogiri::XML::Element }
    end

    # Return array of node-value pairs for each XML::Element in
    # syn
    def synopsis_node_value_pairs(syn)
      synopsis_elements(syn).collect {|node| [node.node_name, node.text] }
    end

    # Convenience method returns array of node names for all the
    # XML::Element children in syn
    def synopsis_nodenames(syn)
      synopsis_elements(syn).collect {|node| node.node_name }
    end
  end

  def initialize(xml_fname)
    File.open(xml_fname) {|f| @doc = Nokogiri::XML(f) }
  end

  def funding_opportunity_synopses
    @doc.xpath('//FundingOppSynopsis')
  end

  def funding_opportunity_modifications
    @doc.xpath('//FundingOppModSynopsis')
  end
end

if __FILE__ == $0
  require 'minitest/autorun'
  require 'set'

  # open Enumerable module to add histogram method to aid sanity check
  # of grants.gov XML extract
  module ::Enumerable
    def histogram
      histo = Hash.new {0}
      self.each {|element| histo[element] += 1 }
      histo
    end
  end

  class GrantsXmlParserTest < Minitest::Test
    def get_parser
      @@parser ||= GrantsXmlParser.new('GrantsDBExtract.xml')
    end

    def get_modifications
      @@modifications ||= get_parser.funding_opportunity_modifications
    end

    def get_synopses
      @@synopses ||= get_parser.funding_opportunity_synopses
    end

    def test_initialize
      refute_nil get_parser
    end

    def test_modifications
      assert get_modifications.size >= 10586
    end

    def test_synopses
      assert get_synopses.size >= 19211
    end

    def test_first_mod
      mod = get_modifications[0]
      assert_instance_of Nokogiri::XML::Element, mod
      assert_equal 81, mod.children.size
    end

    def test_first_synopsis
      syn = get_synopses[0]
      assert_instance_of Nokogiri::XML::Element, syn
      assert_equal 57, syn.children.size
    end

    def test_modification_nodenames
      assert_synopsis_nodenames(get_modifications[0])
    end

    def test_opportunity_nodenames
      assert_synopsis_nodenames(get_synopses[0])
    end

    def assert_synopsis_nodenames(syn)
      nodenames = GrantsXmlParser.synopsis_nodenames(syn)

      expected = all_nodes.sort.uniq
      actual = nodenames.sort.uniq

      assert_equal [], expected-actual, 'fewer nodenames than expected'
      assert_equal [], actual-expected, 'more nodenames than expected'
    end

    def test_nodenames_uniqueness
      repeats = Set.new
      uniques = Set.new
      get_synopses.each do |syn|
        nodenames = GrantsXmlParser.synopsis_nodenames(syn)
        histogram = nodenames.histogram

        # cycle thru each histogram to determine
        histogram.each do |name, count|
          if count == 1
            uniques << name unless repeats.include?(name)
          elsif count > 1
            repeats << name
            uniques.delete(name)
          end
        end
      end

      assert_equal repeated_nodes, repeats.sort
      assert_equal all_nodes - repeated_nodes, uniques.sort
    end

    def repeated_nodes
      [
        "CFDANumber",
        "EligibilityCategory",
        "FundingActivityCategory",
        "FundingInstrumentType",
      ]
    end

    def all_nodes
      [
        "AdditionalEligibilityInfo",
        "Agency",			# 39 values including "None"
        "AgencyContact",		# data only in attributes
        "AgencyMailingAddress",		# data also in attr FundingOppURL
        "ApplicationsDueDate",
        "ApplicationsDueDateExplanation",
        "ArchiveDate",			# mmddyyyy
        "AwardCeiling",
        "AwardFloor",
        "CFDANumber",
        "CostSharing",
        "EligibilityCategory",
        "EstimatedFunding",
        "FundingActivityCategory",
        "FundingInstrumentType",
        "FundingOppDescription",
        "FundingOppNumber",
        "FundingOppTitle",
        "Location",
        "NumberOfAwards",
        "ObtainFundingOppText",
        "Office",
        "OtherCategoryExplanation",
        "Password",
        "PostDate",
        "UserID",
      ]
    end
  end

end

