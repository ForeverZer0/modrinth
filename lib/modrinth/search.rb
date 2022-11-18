# frozen_string_literal: true

require_relative 'facet'

module Modrinth

  ##
  # Represents a search query with support for pagination.
  #
  # Uses lazy-loading to only execute the API call when results are actually queried, not
  # when the {Search} object is initialized. Each page of results is cached internally,
  # meaning subsequent calls to the same page from a {Search} will not result in multiple
  # API calls or count against the [limit](https://docs.modrinth.com/api-spec/#section/Ratelimits) 
  # enforced by Modrinth.
  #
  # @example Pagination and Caching
  #   search = Search.new('shaders', 20, facets: Facet.new(:versions, '1.19.2'))
  #   
  #   # First API call
  #   result_array = search.page(0)
  #
  #   # Second API call
  #   result_array = search.page(1)
  #
  #   # No API call, returns cached results from previous invocation
  #   result_array = search.page(0)
  #
  # @note While this class uses {Enumerable} as a mixin for convenience, consideration must be made
  #   for the {#each} method and any method supplied by {Enumerable}, as it will typically make
  #   multiple API calls for each "page" of results. This happens transparently to the user, but
  #   depending on the number of results returned by a query, could even overcome the rate limit. 
  #   If you know that you will be iterating through all results, use a larger {#page_size} during
  #   initialization to mitigate the number of remote invocations.
  class Search 

    include Enumerable

    ##
    # Describes the supported search indices that can be used for sorting results.
    # @return [Array<Symbol>]
    INDICES = %i(relevance downloads follows newest updated).freeze

    ##
    # @return [String] the search query.
    attr_reader :query

    ##
    # An array containing optimized filters for search results.
    #
    # Facets use `AND/OR` logic depending on how the array is configured.
    # All elements in a single array **after the first one** are considered in a single `OR` block. 
    # All arrays in the top-level one are considered in a single `AND` block. 
    #
    # @example OR
    #   # Translates to "Projects that supports 1.18.1 OR 1.19.2"
    #   search.facets << [Facet.new(:versions, '1.18.1'), Facet.new(:versions, '1.19.2')]
    #   
    # @example AND
    #   # Translates to "Projects that support 1.16.5 AND are modpacks" 
    #   search.facets << [Facet.new(:versions, '1.16.5')]
    #   search.facets << [Facet.new(:project_type, :modpack)]
    #
    # @return [Array<Array<Facet>>]
    # @see https://docs.modrinth.com/docs/tutorials/api_search/#facets
    attr_reader :facets
    
    ##
    # A string expression defining filters for search results. 
    #
    # Filters are string expressions that can used to create fine-grained criteria for
    # a search query, but are likewise more complicated and significantly slower than
    # using facets. Use filters when there isn't an available facet for your needs.
    #
    # @example
    #   filter = 'categories="fabric" AND (categories="technology" OR categories="utility")'
    #   search = Modrinth.search(filter: filter) 
    #
    # @return [String,nil]
    # @see https://docs.meilisearch.com/learn/advanced/filtering_and_faceted_search.html#using-filters Using Filters
    attr_reader :filters

    ##
    # @return [Symbol] a {Symbol} describing the sorting method for results.
    # @see INDICES
    attr_reader :index

    ##
    # @return [Integer] the number of results returned per "page".
    # @see page
    # @see each_page
    attr_reader :page_size

    ##
    # @api private
    # Initializes a new instance of the {Search} class.
    # @param query [String,nil] The query string to seach for.
    # @param page_size [Integer] The page size for paginated results.
    # @param params [Hash{Symbol,Object}] JSON objects representing the object.
    # @see Mordinth.search
    def initialize(query = nil, page_size = 10, **params)
      @page_size = page_size.to_i.clamp(1, 100)
      @offset = 0
      @total = -1
      @pages = []

      @query = query
      params.each_pair do |key, value|
        case key.to_sym
        when :facets
          @facets = parse_facets(value)
        when :filters
          @filters = parse_filters(value)
        when :index, :sort
          @index = value.to_sym
          raise(ArgumentError, "invalid index \"#{index}\" specified") unless INDICES.include?(@index)
        end
      end

      @index ||= :relevance
      @facets ||= []
      @filters ||= []
    end

    ##
    # The total number of search results.
    # @return [Integer] the total number of results, or `-1` if no API call has yet been made.
    def size
      @total
    end

    ##
    # Iterates through the results of the query. 
    #
    # @note While this class uses {Enumerable} as a mixin for convenience, consideration must be made
    #   for the {#each} method and any method supplied by {Enumerable}, as it will typically make
    #   multiple API calls for each "page" of results. This happens transparently to the user, but
    #   depending on the number of results returned by a query, could even overcome the rate limit. 
    #   If you know that you will be iterating through all results, use a larger {#page_size} during
    #   initialization to mitigate the number of remote invocations.
    #
    # @overload each(&block)
    #   When called with a block, yields each result to the block.
    #   @yieldparam result [SearchResult] A {SearchResult} object.
    #   @return [void]
    #
    # @overload each
    #   When called without a block, returns an {Enumerator} for the search results.
    #   @return [Enumerator] an {Enumerator} for the results.
    #
    # @see each_page
    def each
      return enum_for(__method__) unless block_given?
      each_page do |page|
        break unless page
        page.each { |result| yield result }
      end
    end

    ##
    # Retrieves the search resuls for the specified page.
    #
    # @param index [Integer] the zero-based index of the page to retrieve.
    # @return [Array<SearchResult>] the search results for the page.
    #
    # @note The size of the returned array will not exceed the value of {#page_size}.
    # @see each_page
    def page(index)
      i = [index, 0].max
      @pages[i] ||= call(i * @page_size) || false
    end

    ##
    # Iterates through each page of results, returing each page as a an {Array} of {SearchResult} objects.
    #
    # @note The size of the _results_ array will not exceed the value of {#page_size}.
    #
    # @overload each_page(&block)
    #   When called with a block, yields an {Array} containing the search results for the page.
    #   @yieldparam results [Array<SearchResult>] An array of {SearchResult} objects.
    #   @return [void]
    #
    # @overload each_page
    #   When called without a block, returns an {Enumerator} for the search results.
    #   @return [Enumerator] an {Enumerator} for the results.
    # 
    # @see page
    # @see each
    def each_page
      return enum_for(__method__) unless block_given?
      n = 0
      loop do
        results = page(n)
        break unless results
        yield results
      end
    end

    alias_method :limit, :page_size

    private 

    ##
    # Parses facet values.
    # @param value [Array<Facet>,Facet,String] The {Facet} value.
    # @return [Array<Facet>]
    def parse_facets(value)
      results = []
      case value
      when Array
        results += value.flat_map { |item| parse_facets(item) }
      when Facet
        results.push(value)
      when String
        results.push(Facet.parse(value))
      end
      results
    end

    ## 
    # @api private
    # Executes the `/search` API call, and returns the results as a JSON object.
    # @param offset [Integer] the offset into results to begin the query.
    # @return [Hash{Symbol,Object},nil] the JSON results.
    def call(offset)

      return nil if @total >= 0 && offset > @total
        
      params = {}
      params['query'] = @query if @query
      params['facets'] = @facets.to_json unless @facets.empty?
      params['index'] = index

      params['offset'] = offset
      params['limit'] = @page_size
      params['filters'] = @filters if @filters

      json = Modrinth::Net.get(Route::SEARCH, **params)
      return nil unless json

      @offset = json[:offset]
      @page_size = json[:limit]
      @total = json[:total_hits]
      json[:hits].map { |hit| SearchResult.from_json(hit) }
    end

  end

end