# frozen_string_literal: true

require 'json'
require 'time'

require_relative "modrinth/gem_version"
require_relative 'modrinth/net'
require_relative 'modrinth/search'
require_relative 'modrinth/project'
require_relative 'modrinth/version'

##
# Top-level namespace for the Modrinth API.
module Modrinth

  ##
  # Describes categories that projects can be classified with.
  #
  # @attribute [r] icon
  #   @return [String] the SVG icon of a category.
  # @attribute [r] name
  #   @return [String] the name of the category.
  # @attribute [r] project_type 
  #   @return [Symbol] the project type this category is applicable to.
  #   @see Project::TYPES
  # @attribute [r] header 
  #   @return [String] the header under which the category should go.
  Category = Struct.new(:icon, :name, :project_type, :header)

  ##
  # Describes mod-loaders supported by the API.
  #
  # @attribute [r] icon
  #   @return [String] the SVG icon of a loader.
  # @attribute [r] name
  #   @return [String] the name of the loader.
  # @attribute [r] project_type 
  #   @return [Array<Symbol>] the project types that this loader is applicable to.
  #   @see Project::TYPES
  Loader = Struct.new(:icon, :name, :project_types)

  ##
  # Describes Minecraft game versions.
  #
  # @attribute [r] version
  #   @return [String] the name/number of the game version.
  # @attribute [r] version_type
  #   The type of the game version. Valid values include:
  #     * `:release`
  #     * `:snapshot`
  #     * `:alpha`
  #     * `:beta`
  #   @return [Symbol] the type of the game version. 
  # @attribute [r] date
  #   @return [DateTime] the date of the game version release.
  # @attribute [r] major
  #   @return [Boolean] flag indicating whether or not this is a major version, used for Featured Versions.
  GameVersion = Struct.new(:version, :version_type, :date, :major)

  ##
  # Describes a license for a project.
  #
  # @attribute [rw] id
  #   @return [String] the short identifier of the license.
  # @attribute [rw] name
  #   @return [String] the full name of the license.
  # @attribute [rw] url
  #   @return [String,nil] the optional URL to the license.
  License = Struct.new(:id, :name, :url)

  ##
  # Describes a supported donation platform for a project.
  # 
  # @attribute [rw] id
  #   @return [String] the short identifier of the donation platform.
  # @attribute [rw] name
  #   @return [String] the full name of the donation platform.
  # @attribute [rw] url
  #   @return [String,nil] the optional URL to the donation platform.
  DonationPlatform = Struct.new(:id, :name, :url)

  ##
  # Describes a moderator message.
  #
  # @attribute [r] message
  #   @return [String] the message that a moderator has left for the project.
  # @attribute [r] body
  #   @return [String,nil] the longer body of the message that a moderator has left for the project.
  ModeratorMessage = Struct.new(:message, :body)

  ##
  # Gets an array of categories, their icons, and applicable project types.
  # @return [Array<Category>] the array of supported categories.
  # @see Project::TYPES
  def self.categories
    if @categories.nil?
      json = Modrinth::Net.get('/tag/category')
      @categories = json.map { |j| Category.new(j[:icon], j[:name], j[:project_type].to_sym, j[:header]) }
    end
    @categories
  end

  ##
  # Gets an array of loaders, their icons, and supported project types.
  # @return [Array<Loader>] the array of supported loaders.
  # @see Project::TYPES
  def self.loaders
    if @loaders.nil?
      json = Modrinth::Net.get('/tag/loader')
      @loaders = json.map { |j| Loader.new(j[:icon], j[:name], j[:supported_project_types].map(&:to_sym)) }
    end
    @loaders
  end

  ##
  # Gets an array of game versions and information about them.
  # @return [Array<GameVersion>] the array of supported game versions.
  def self.game_versions
    if @game_versions.nil?
      json = Modrinth::Net.get('/tag/game_version')
      @game_versions = json.map { |j| GameVersion.new(
          j[:version], 
          j[:version_type.to_sym], 
          DateTime.iso8601(j[:date]),
          j[:major])
      }
    end
    @game_versions
  end

  ##
  # Gets an array of licenses and information about them.
  # @return [Array<License>] the array of known licenses.
  def self.licenses
    if @licenses.nil?
      json = Modrinth::Net.get('/tag/license')
      @licenses = json.map { |j| License.new(j[:short], j[:name]) }
    end
    @licenses
  end

  ##
  # Gets an array of donation platforms and information about them.
  # @return [Array<DonationPlatform>] an array of supported donation platforms.
  def self.donation_platforms
    if @donation_platforms.nil?
      json = Modrinth::Net.get('/tag/donation_platform')
      @donation_platforms = json.map { |j| DonationPlatform.new(j[:short], j[:name]) }
    end
    @donation_platforms
  end
 
  ##
  # @return [Array<String>] an array of valid report types.
  def self.report_types
    @report_types ||= Modrinth::Net.get('/tag/report_type')
  end

  ##
  # Performs a search query of the Modrinth modding platform.
  #
  # @param query [String,nil] The query string to seach for.
  # @param page_size [Integer] The page size for paginated results.
  # @param options [Hash{Symbol,Object}] The options hash.
  #
  # @option options [Array,Facet,String] :facets ([])
  # @option options [Array,Filter,String] :filters ([])
  # @option options [Symbol] :index (:relevance)
  #
  # @return [Search] a {Search} object that can be enumerated for search results.
  def self.search(query = nil, page_size = 10, **options)
    Search.new(query, page_size, **options)
  end

  ##
  # Retrieves a {Project} with the specified ID or _slug_.
  #
  # @param id_or_slug [String] The unique ID or vanity slug associated with the project.
  # @return [Project,nil] the specified {Project}, or `nil` if an error occurred or project was not found.
  def self.project(id_or_slug)
    json = Net.get("/project/#{id_or_slug}") rescue nil
    json ? Project.new(**json) : nil
  end

end