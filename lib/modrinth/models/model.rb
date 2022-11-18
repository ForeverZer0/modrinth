# frozen_string_literal: true

module Modrinth

  ##
  # @abstract
  # Abstract base-class for generic data types that can be represented in JSON format.
  class Model

    ##
    # Creates a new instance from a JSON object.
    # @param json [Hash{Symbol,Object}] A {Hash} representing the JSON object.
    # @return [Model] the newly created instance.
    def self.from_json(json)
      obj = allocate
      json.each_pair do |key, value|
        obj.instance_variable_set("@#{key}", value)
      end
      obj
    end

    ##
    # Parses a new instance from the specified JSON string.
    # @param json_string [String] A JSON string to parse.
    # @return [klass,nil] the newly created {DonationPlatform}, or `nil` if parsing failed.
    def self.parse(json_string)
      begin
        json = JSON.parse(json_string, symbolize_names: true)
        from_json(json)
      rescue
        nil
      end
    end

    ##
    # Returns the object in a compatible JavaScript Object Notation (JSON) representation.
    # @param pretty [Boolean] Flag indicating if generated JSON should be formatted and spaced for readability.
    # @return [Hash{Symbol,Object}] The JSON object.
    def to_json(pretty = false)
      hash = self.to_h
      pretty ? JSON.pretty_generate(hash, indent: '    ') : hash.to_json(nil)
    end

    ##
    # Returns the object represented as a {Hash}.
    # @return [Hash{Symbol,Object}] the {Hash} representatin of the object.
    def to_h
      hash = {}
      instance_variables.each do |ivar|
        key = ivar.to_s.sub(/^@/, '').to_sym
        hash[key] = instance_variable_get(ivar)
      end
      hash.compact
    end

    ##
    # Retrieves the object instance represented as a {String}.
    # @return [String] the string representation of the instance. 
    def to_s
      super
    end
  end
end