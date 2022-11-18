# frozen_string_literal: true

module Modrinth

  ##
  # Describes categories that projects can be classified with.
  class Category < Model

    ##
    # @return [String] the SVG icon of a category.
    # @see Modrinth.svg2img
    attr_accessor :icon

    ##
    # @return [String] the name of the category.
    attr_accessor :name

    ##
    # @return [Symbol] the project type this category is applicable to.
    # @see Project::TYPES
    attr_accessor :project_type

    ##
    # @return [String] the header under which the category should go.
    attr_accessor :header

    ##
    #
    # @param icon [String] The SVG icon of a category.
    # @param name [String] The name of the category.
    # @param project_type [Symbol,String] The project type this category is applicable to.
    # @param header [String] The header under which the category should go.
    def initialize(icon, name, project_type, header)
      @icon = icon
      @name = name
      @project_type = project_type.to_sym
      @header = header
    end

    ##
    # Creates a new instance from a JSON object.
    # @param json [Hash{Symbol,Object}] A {Hash} representing the JSON object.
    # @return [Category] the newly created instance.
    def self.from_json(json)
      new(json[:icon], json[:name], json[:project_type], json[:header])
    end

    ##
    # (see Model#to_s)
    def to_s
      @name
    end
  end
end