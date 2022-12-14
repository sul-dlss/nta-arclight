# frozen_string_literal: true

# Represent a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document
  include Arclight::SolrDocument

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  attribute :media_type, Blacklight::Types::String, 'media_type_ssi'

  # Suppress the display of extent badge when there is only one item
  def extent
    result = Blacklight::Types::String.coerce(self['extent_ssm'])
    return result if result != '1 item(s)'
  end

  def full_text_highlights
    highlighting_response = response.dig('highlighting', id) || {}
    all_results = highlighting_response.slice('full_text_tesimv').values.flatten.compact

    all_results.uniq do |value|
      value.gsub(%r{</?em>}, '')
    end
  end
end
