# frozen_string_literal: true

module Modrinth

  ##
  # Describes a license for a project.
  # @see Modrinth.licenses
  class License < Model

    ##
    # @return [String] the short identifier of the license.
    attr_accessor :id

    ##
    # @return [String] the full name of the license.
    attr_accessor :name

    ##
    # @return [String,nil] the optional URL to the license.
    attr_accessor :url

    ##
    # Initializes a new instance of the {License} class.
    # @param id [String,Symbol] The short identifier of the license.
    # @param name [String] The full name of the license.
    # @param url [String,nil] The optional URL to the license.
    def initialize(id, name, url = nil)
      @id = id.to_s
      @name = name
      @url = url
    end

    ##
    # Creates a new instance from a JSON object.
    # @param json [Hash{Symbol,Object}] A {Hash} representing the JSON object.
    # @return [License] the newly created instance.
    def self.from_json(json)
      new(json[:id] || json[:short], json[:name], json[:url])
    end

    ##
    # (see Model#to_s)
    def to_s
      @name
    end

    ##
    # Compares _other_ object for equality to this instance.
    # @param other [Object,nil] The object to compare for equality.
    # @return [Boolean] `true` if _other_ is a {License} with the same ID, otherwise `false`.
    def ==(other)
      other.is_a?(License) && other.id == @id
    end

    alias_method :eql?, :==
  end
end