# frozen_string_literal: true

module Modrinth

  ##
  # @api private
  # Defines remote endpoints and methods for URI building.
  module Route

    ##
    # The base URL for the Modrinth REST API.
    # @return [String]
    API_BASE = 'https://api.modrinth.com/v2'

    ##
    # Endpoint for category list.
    # @return [String]
    TAG_CATEGORY = '/tag/category'

    ##
    # Endpoint for loader list.
    # @return [String]
    TAG_LOADER = '/tag/loader'

    ##
    # Endpoint for game version list.
    # @return [String]
    TAG_GAME_VERSION = '/tag/game_version'

    ##
    # Endpoint for license list.
    # @return [String]
    TAG_LICENSE = '/tag/license'

    ##
    # Endpoint for donation platform list.
    # @return [String]
    TAG_DONATION = '/tag/donation_platform'

    ##
    # Endpoint for report type list.
    # @return [String]
    TAG_REPORT_TYPE = '/tag/report_type'

    ##
    # Endpoint for search API.
    # @return [String]
    SEARCH = '/search'

    ##
    # Endpoint for project query.
    # @note Format string with project slug or ID must be supplied.
    # @return [String]
    PROJECT = '/project/%s'

    USER = '/user/%s'

    PROJECT_TEAM = '/project/%s/membes'

    TEAM = '/team/%s/members'

    ##
    # Builds a URI.
    # @param method [String] The relative Modrinth API endpoint.
    # @param format [Array] Optional format arguments that will be used for string substituion.
    # @param params [Hash] Options hash containing query parameters.
    # @return [URI] the newly constructed URI instance.
    def self.build(method, *format, **params)
      uri = URI(API_BASE + sprintf(method, *format))
      uri.query = URI.encode_www_form(params) if params
      uri
    end
  end
end