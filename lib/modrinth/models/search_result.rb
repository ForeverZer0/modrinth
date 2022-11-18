# frozen_string_literal: true

module Modrinth

  ##
  # Describes a single project result in a {Search} query.
  class SearchResult < Model

    ##
    # @return [String] the slug of a project, used for vanity URLs.
    # @see SLUG_PATTERN
    attr_accessor :slug

    ##
    # @return [String] the title or name of the project.
    attr_accessor :title

    ##
    # @return [String] a short description of the project.
    attr_accessor :description

    ##
    # @return [Array<String>] a list of the categories that the project has.
    attr_accessor :categories

    ##
    # @return [Symbol] a {Symbol} describing the client side support of the project.
    # @see Project::SUPPORT
    attr_accessor :client_side

    ##
    # @return [Symbol] a {Symbol} describing the server side support of the project.
    # @see Project::SUPPORT
    attr_accessor :client_side

    ##
    # @return [Symbol] a {Symbol} describing the project type of the project.
    # @see Project::TYPES
    attr_accessor :project_type

    ##
    # @return [Integer] the total number of downloads of the project.
    attr_accessor :downloads

    ##
    # @return [String,nil] the URL of the project's icon.
    attr_accessor :icon_url

    ##
    # @return [String] the ID of the project.
    attr_accessor :project_id

    ##
    # @return [String] the username of the project's author.
    attr_accessor :author

    ##
    # @return [Array<String>] a list of the categories that the project has which are not secondary.
    attr_accessor :display_categories

    ##
    # @return [Array<String>] a list of the Minecraft versions supported by the project.
    attr_accessor :versions
 
    ##
    # @return [Integer] the total number of users following the project.
    attr_accessor :follows

    ##
    # @return [String] the date the project was added to search.
    attr_accessor :date_created

    ##
    # @return [String] the date the project was last modified.
    attr_accessor :date_modified

    ##
    # @return [String,nil] the latest version of Minecraft that this project supports.
    # @note Value may be `nil` when project is in `draft` status.
    attr_accessor :latest_version

    ##
    # @return [String] the license of the project.
    attr_accessor :license

    ##
    # @return [Array<String>] all gallery images attached to the project.
    attr_accessor :gallery

    ##
    # Creates a new instance from a JSON object.
    # @param json [Hash{Symbol,Object}] A {Hash} representing the JSON object.
    # @return [SearchResult] the newly created instance.
    def self.from_json(json)
      result = allocate

      %i(slug title description downloads icon_url project_id author versions follows latest_version license).each do |sym|
        result.instance_variable_set("@#{sym}", json[sym])
      end

      %i(client_side server_side project_type).each do |sym|
        result.instance_variable_set("@#{sym}", json[sym]&.to_sym)
      end

      result.categories = json[:categories] || Array.new
      result.display_categories = json[:display_categories] || Array.new
      result.gallery = json[:gallery] || Array.new
      result.date_created = Modrinth::Net.parse_date(json[:date_created])
      result.date_modified = Modrinth::Net.parse_date(json[:date_modified])
      
      result
    end

    ##
    # (see Model#to_h)
    def to_h
      hash = super
      hash[:date_created] = @date_created.iso8601
      @hash[:date_modified] = @data_modified.iso8601
      hash
    end

    ##
    # (see Model#to_s)
    def to_s
      @title || super
    end

    ##
    # Compares equality of this {SearchResult} with another object.
    # @param other [Object,nil] The object insatnce to compare for equality.
    # @return [Boolean] `true` if _other_ is a {SearchResult} with the same ID, otherwise `false`.
    def ==(other)
      other.is_a?(SearchResult) && other.project_id == @project_id
    end

    ##
    # Retrieves the associated {Project} instance for this {SearchResult}.
    # @return [Project] the project instance.
    def project
      @project ||= Modrinth.project(@project_id)
    end

    alias_method :eql?, :==
  end
end