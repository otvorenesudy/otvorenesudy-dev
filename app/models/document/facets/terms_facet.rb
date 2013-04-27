class Document::Facets::TermsFacet < Document::Facets::Facet

  def build(facet, field)
    facet.terms field, size: @size
  end

  def build_filter
    terms.map do |value|
      { term: { not_analyzed_field(@field) => value } }
    end
  end

  private

  def format_facets(results)
    results['terms'].map do |term|
      format_term(term)
    end
  end

  def format_term(term)
    { value: term['term'], count: term['count'] }
  end

end