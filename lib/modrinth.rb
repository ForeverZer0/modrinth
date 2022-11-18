# frozen_string_literal: true

require 'digest'
require 'json'
require 'time'

require_relative 'modrinth/gem_version'
require_relative 'modrinth/route'
require_relative 'modrinth/net'

require_relative 'modrinth/models'
require_relative 'modrinth/search'

##
# Top-level namespace for the Modrinth API.
module Modrinth

  # @!group Tags

  ##
  # Gets an array of game versions and information about them.
  # @return [Array<GameVersion>] the array of supported game versions.
  def self.game_versions
    @game_versions ||= Modrinth::Net.tags(GameVersion, Route::TAG_GAME_VERSION)
  end

  ##
  # Gets an array of loaders, their icons, and supported project types.
  # @return [Array<Loader>] the array of supported loaders.
  def self.loaders
    @loaders ||= Modrinth::Net.tags(Loader, Route::TAG_LOADER)
  end

  ##
  # Gets an array of licenses and information about them.
  # @return [Array<License>] the array of known licenses.
  def self.licenses
    @licenses ||= Modrinth::Net.tags(License, Route::TAG_LICENSE)
  end

  ##
  # Gets an array of categories, their icons, and applicable project types.
  # @return [Array<Category>] the array of supported categories.
  # @see Project::TYPES
  def self.categories
    @categories ||= Modrinth::Net.tags(Category, Route::TAG_CATEGORY)
  end

  ##
  # Gets an array of donation platforms and information about them.
  # @return [Array<DonationPlatform>] an array of supported donation platforms.
  def self.donation_platforms
    @donation_platforms ||= Modrinth::Net.tags(DonationPlatform, Route::TAG_DONATION)
  end
 
  ##
  # @return [Array<String>] an array of valid report types.
  def self.report_types
    @report_types ||= Modrinth::Net.get(Route::TAG_REPORT_TYPE)
  end

  # @!endgroup

  # @!group Projects

  ##
  # Performs a search query of the Modrinth modding platform.
  #
  # @param query [String,nil] The query string to seach for.
  # @param page_size [Integer] The page size for paginated results. Value is clamped between `1` and `100` inclusive.
  # @param options [Hash{Symbol,Object}] The options hash.
  #
  # @option options [Array,Facet,String] :facets ([])
  # @option options [Array,Filter,String] :filters ([])
  # @option options [Symbol] :index (:relevance) The search index used for ordering results.
  #
  # @return [Search] a {Search} object that can be enumerated for results.
  def self.search(query = nil, page_size = 10, **options)
    Search.new(query, page_size, **options)
  end

  ##
  # Retrieves a {Project} with the specified ID or _slug_.
  #
  # @param id_or_slug [String] The unique ID or vanity slug associated with the project.
  # @return [Project,nil] the specified {Project}, or `nil` if an error occurred or project was not found.
  def self.project(id_or_slug)
    json = Modrinth::Net.get(Route::PROJECT, id_or_slug)
    json ? Project.from_json(json) : nil # TODO
  end

  ##
  # Modifies an existing project.
  #
  # @param project [Project,String] the {Project} instance, the project slug, or project ID to modify.
  # @param fields [Hash] The options hash containing the project fields to be modified. Only the fields
  #   that are to be modified need to be included.
  # 
  # @option fields [String] :slug The slug of a project, used for vanity URLs. Must match the {Project::SLUG_PATTERN}.
  # @option fields [String] :title The title or name of the project.
  # @option fields [String] :description A short description of the project.
  # @option fields [Array<String>] :categories A list of the categories that the project has.
  # @option fields [Symbol,String] :client_side The client side support of the project, one of `:required`, `:optional`, `:unsupported`.
  # @option fields [Symbol,String] :server_side The server side support of the project, one of `:required`, `:optional`, `:unsupported`.
  # @option fields [String] :body A long form description of the project.
  # @option fields [Array<Array<String>>] :additional_categories # TODO
  # @option fields [String,nil] :issues_url An optional link to where to submit bugs or issues with the project.
  # @option fields [String,nil] :source_url An optional link to the source code of the project.
  # @option fields [String,nil] :wiki_url An optional link to the project's wiki page or other relevant information.
  # @option fields [String,nil] :discord_url An optional invite link to the project's Discord.
  # @option fields [String] :donation_urls A list of donation links for the project. # TODO Not a string, but DonationPlatform
  # @option fields [String] :license_id The license ID of a project, retrieved from the license tag route.
  # @option fields [String,nil] :license_url The URL to the license.
  # @option fields [Symbol,String] :status The status of the project, one
  #   of `:approved`, `:rejected`, `draft`, `:unlisted`, `:archived`, `:processing`, or `:unknown`.
  # @option fields [String,nil] :moderation_message The title of the moderators' message for the project.
  # @option fields [String,nil] :moderation_message_body The body of the moderators' message for the project.
  #
  # @note This method requires token authentification by defining the `MODRINTH_TOKEN`
  #   environment variable before program startup.
  def self.modify_project(project, **fields)

  end





  def self.user(id_or_username)
    json = Modrinth::Net.get(Route::USER, id_or_username)
    json ? User.from_json(json) : nil # TODO
  end



  def self.team(id)
    json = Modrinth::Net.get(Route::TEAM, id)
    return nil unless json.is_a?(Array)
    json.map { |hash| TeamMember.from_json(hash) }
  end
end