# frozen_string_literal: true

module Modrinth

  ##
  # Describes a single project result in a {Search} query.
  class SearchResult

    ##
    # @return [String] the slug of a project, used for vanity URLs.
    # @see SLUG_PATTERN
    attr_reader :slug

    ##
    # @return [String] the title or name of the project.
    attr_reader :title

    ##
    # @return [String] a short description of the project.
    attr_reader :description

    ##
    # @return [Array<String>] a list of the categories that the project has.
    attr_reader :categories

    ##
    # @return [Symbol] a {Symbol} describing the client side support of the project.
    # @see Project::SUPPORT
    attr_reader :client_side

    ##
    # @return [Symbol] a {Symbol} describing the server side support of the project.
    # @see Project::SUPPORT
    attr_reader :client_side

    ##
    # @return [Symbol] a {Symbol} describing the project type of the project.
    # @see Project::TYPES
    attr_reader :project_type

    ##
    # @return [Integer] the total number of downloads of the project.
    attr_reader :downloads

    ##
    # @return [String,nil] the URL of the project's icon.
    attr_reader :icon_url

    ##
    # @return [String] the ID of the project.
    attr_reader :project_id

    ##
    # @return [String] the username of the project's author.
    attr_reader :author

    ##
    # @return [Array<String>] a list of the categories that the project has which are not secondary.
    attr_reader :display_categories

    ##
    # @return [Array<String>] a list of the Minecraft versions supported by the project.
    attr_reader :versions
 
    ##
    # @return [Integer] the total number of users following the project.
    attr_reader :follows

    ##
    # @return [String] the date the project was added to search.
    attr_reader :date_created

    ##
    # @return [String] the date the project was last modified.
    attr_reader :date_modified

    ##
    # @return [String,nil] the latest version of minecraft that this project supports.
    # @note Value may be `nil` when project is in `draft` status.
    attr_reader :latest_version

    ##
    # @return [String] the license of the project.
    attr_reader :license

    ##
    # @return [Array<String>] all gallery images attached to the project.
    attr_reader :gallery

    ##
    # @api private
    # Initializes a new instance of the {SearchResult} class.
    # @param params [Hash{Symbol,Object}] JSON objects representing the object.
    def initialize(**params)
      @slug = params[:slug]
      @title = params[:title]
      @description = params[:description]
      @categories = params[:categories] || Array.new
      @client_side = params[:client_side].to_sym
      @server_side = params[:server_side].to_sym
      @project_type = params[:project_type].to_sym
      @downloads = params[:downloads]
      @icon_url = params[:icon_url]
      @project_id = params[:project_id]
      @author = params[:author]
      @display_categories = params[:display_categories] || Array.new
      @versions = params[:versions]
      @follows = params[:follows]
      @date_created = DateTime.iso8601(params[:date_created])
      @date_modified = DateTime.iso8601(params[:date_modified])
      @latest_version = params[:latest_version]
      @license = params[:license]
      @gallery = params[:gallery] || Array.new
    end

    ##
    # @return [String] the {String} representation of the {SearchResult}.
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

    alias_method :eql?, :==

    # TODO: to_project

  end
end