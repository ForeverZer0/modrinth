# frozen_string_literal: true

module Modrinth

  ##
  # Describes an optimized filter for search results that uses a limited set of criteria.
  class Facet

    ##
    # An array containing the supported facet types.
    # @return [Array<Symbol>] 
    TYPES = %i(categories versions license project_type).freeze

    ##
    # @return [Symbol] The facet type.
    # @see TYPES
    attr_reader :type
    
    ##
    # @return [String] The value of the facet.
    attr_reader :value

    ##
    # Initializes a new instance of the {Facet} class.
    #
    # @param type [Symbol,String] Describes the facet type, which must be one of the following:
    #
    #   | Type            | Description |
    #   | :---            | :---        |
    #   | `:categories`   | The loader or category to filter the results from.
    #   | `:version`      | The Minecraft version to filter the results from.
    #   | `:license`      | The license ID to filter the results from.
    #   | `:project_type` | The project type to filter the results from.
    #
    # @param value [String,Symbol]
    #
    # @see TYPES
    # @raise [ArgumentError] when _type_ is invalid or _value_ is `nil`.
    def initialize(type, value)
      @type = type.to_sym
      @value = value || raise(ArgumentError, 'value cannot be nil')
      raise(ArgumentError, "invalid facet type") unless TYPES.include?(@type)
    end

    ##
    # Retrieves a {String} that describes the facet.
    # @return [String] the {String} representation of the facet.
    def to_s
      "\"#{@type}:#{@value}\""
    end

    ##
    # Retrieves the {Facet} represented in JavaScript Object Notation (JSON).
    # @param options [Symbol,nil] Unused.
    # @return [String] the {Facet} as a JSON string.
    def to_json(options = nil)
      to_s
    end

    class << self

      ##
      # Parses a new {Facet} from the specified _string_.
      # @param string [String] The {String} to parse.
      # @return [Facet,nil] a new {Facet} instance or `nil` if parsing failed.
      def parse(string)
        return nil unless /^(\w+):"?(.*?)"?$/.match(str)
        new($1, $2)
      end

      ##
      # Convenience method to create one or more category facets.
      #
      # @param values [String,Array<String>] The value(s) to be created.
      # @return [Facet,Array<Facet>] when _values_ is a single string, returns the newly created {Facet},
      #   otherwise returns an array of the facets when multiple values are given.
      # @raise [ArgumentError] when no values are specified.
      def categories(*values)
        create(:categories, values)
      end
  
      ##
      # Convenience method to create one or more version facets.
      #
      # @param values [String,Array<String>] The value(s) to be created.
      # @return [Facet,Array<Facet>] when _values_ is a single string, returns the newly created {Facet},
      #   otherwise returns an array of the facets when multiple values are given.
      # @raise [ArgumentError] when no values are specified.
      def versions(*values)
        create(:versions, values)
      end
  
      ##
      # Convenience method to create one or more license facets.
      #
      # @param values [String,Array<String>] The value(s) to be created.
      # @return [Facet,Array<Facet>] when _values_ is a single string, returns the newly created {Facet},
      #   otherwise returns an array of the facets when multiple values are given.
      # @raise [ArgumentError] when no values are specified.
      def license(*values)
        create(:license, values)
      end
  
      ##
      # Convenience method to create one or more project type facets.
      #
      # @param values [String,Array<String>] The value(s) to be created.
      # @return [Facet,Array<Facet>] when _values_ is a single string, returns the newly created {Facet},
      #   otherwise returns an array of the facets when multiple values are given.
      # @raise [ArgumentError] when no values are specified.
      def project_type(values)
        create(:project_type, values)
      end

      private

      ##
      # Creates multiple instances of the specified type.
      # @param facet_type [Symbol] The type of facet to create.
      # @param values [Array<String>] The values of the facets.
      # @return [Facet,Array<Facet>] The newly created facet(s).
      # @raise [ArgumentError] when no values are specified.
      def create(facet_type, values)
        raise(ArgumentError, 'no facet value specified') unless values.size > 0
        result = values.map { |value| new(facet_type, value) }
        values.size > 1 ? result : result.first
      end
    end
  end
end