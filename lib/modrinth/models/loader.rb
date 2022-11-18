# frozen_string_literal: true

module Modrinth

  ##
  # Describes mod-loaders supported by the API.
  # @see Modrinth.loaders
  class Loader < Model

    ##
    # @return [String] the SVG icon of the loader.
    attr_accessor :icon

    ##
    # @return [String] the name of the loader.
    attr_accessor :name

    ##
    # @return [Array<Symbol>] the project types that this loader is applicable to.
    # @see Project::TYPES
    attr_accessor :project_types

    ##
    # Initializes a new instance of the {Loader} class.
    # @param icon [String] The SVG icon of the loader.
    # @param name [String,Symbol] The name of the loader.
    # @param project_types [Array<Symbol,String>] The project types that this loader is applicable to.
    def initialize(icon, name, project_types)
      @icon = icon
      @name = name.to_s
      @project_types = project_types&.map(&:to_sym) || Array.new
    end

    ##
    # (see Model#to_s)
    def to_s
      @name
    end

    ##
    # (see Model#to_h)
    def to_h
      { icon: @icon, name: @name, supported_project_types: @project_types }.compact
    end

    ##
    # Creates a new instance from a JSON object.
    # @param json [Hash{Symbol,Object}] A {Hash} representing the JSON object.
    # @return [Loader] the newly created instance.
    def self.from_json(json)
      new(json[:icon], json[:name], json[:supported_project_types])
    end

    ##
    # Attempts to parse a {Loader} instance from the specified string.
    #
    # @example
    #   p Loader.from_name('fabric')
    #   #<Modrinth::Loader:0x000056360cd9fe20 @icon="<svg>...</svg>", @name="fabric", @project_types=[:mod, :modpack]>
    #
    # @param name [String] A string containing the name of the Minecraft loader.
    # @return [Loader,nil] the newly created instance if successful, otherwise `nil`.
    # @note The search is case-insensitive.
    def self.from_name(name)
      return nil unless name.is_a?(String)
      Modrinth.loaders.find { |loader| loader.name.casecmp(name).zero? }
    end
  end
end