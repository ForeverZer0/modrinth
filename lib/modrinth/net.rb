# frozen_string_literal: true

require 'net/http'

module Modrinth

  ##
  # @api private
  # Utility module provideing methods for interacting with the remote Modrinth API.
  module Net

    ##
    # Flag indicating if SSL encryption will be used for remote API calls.
    # @return [Boolean]
    SSL = URI(Route::API_BASE).scheme == 'https'

    ##
    # @return [Integer] the maximum number of requests that can be made in a minute.
    attr_reader :rate_limit

    ##
    # @return [Integer] the number of requests remaining in the current rate-limit window.
    attr_reader :rate_remaining

    ##
    # @return [Integer] the time in seconds until the ratelimit window resets.
    attr_reader :rate_reset

    ##
    # @return [Hash{String,String}] default headers to supply with each API call.
    HEADERS = 
    { 
      'User-Agent' => ENV['MODRINTH_AGENT'], 
      'Authorization' => ENV['MODRINTH_TOKEN'],  
      'Accept' => 'application/json' 
    }.compact.freeze
    
    ##
    # @return [String] the base URL for the Modrinth REST API.
    API_BASE = 'https://api.modrinth.com/v2'

    ##
    # Calculates the digest of a file with 160 bits.
    # 
    # @param filename [String] the path to the file to calculate the checksum of.
    # @return [String] the 20-byte checksum of the file.
    def self.sha1(filename)
      File.open(filename, 'rb') { |io| Digest::SHA1.hexdigest(io.read) }
    end

    ##
    # Calculates the digest of a file with chunks of 1024 bits.
    # 
    # @param filename [String] the path to the file to calculate the checksum of.
    # @return [String] the 512-bit checksum of the file.
    def self.sha512(filename)
      File.open(filename, 'rb') { |io| Digest::SHA512.hexdigest(io.read) }
    end

    ##
    # Executes a GET request with the given parameters.
    # @param method [String] The remote endpoint for the method to call.
    # @param format [Array<Object>] Format arguments to pass to the route builder.
    # @param params [Hash] A hash containing the REST query.
    #
    # @note The rate limit is tracked internally and updated with each call from the response headers.
    # @return [Hash{Symbol,Object},nil] the JSON response, or `nil` if a non-successful response was returned.
    def self.get(method, *format, **params)

      uri = Route.build(method, *format, **params)
      response = ::Net::HTTP.start(uri.hostname, uri.port, use_ssl: SSL) do |http|
        request = ::Net::HTTP::Get.new(uri.to_s, HEADERS)
        http.request(request)
      end

      update_rates(response)
      return nil unless response.is_a?(::Net::HTTPSuccess)
      JSON.parse(response.body, symbolize_names: true)
    end

    ##
    # Executes a POST request with the given parameters.
    # @param method [String] The remote endpoint for the method to call.
    # @param payload [Hash] A hash containing the JSON payload defining the message body.
    # @param format [Array<Object>] Format arguments to pass to the route builder.
    # @param params [Hash] A hash containing the REST query.
    #
    # @note The rate limit is tracked internally and updated with each call from the response headers.
    # @return [Hash{Symbol,Object},nil] the JSON response, or `nil` if a non-successful response was returned.
    def self.post(method, payload, *format, **params)

      uri = Route.build(method, *format, **params)
      response = ::Net::HTTP.start(uri.hostname, uri.port, use_ssl: SSL) do |http|
        request = ::Net::HTTP::Post.new(uri, HEADERS)
        request.content_type = 'application/json'
        request.body = payload.to_json
        http.request(request)
      end

      update_rates(response)
      return nil unless response.is_a?(::Net::HTTPSuccess)
      JSON.parse(response.body, symbolize_names: true)  
    end

    ##
    # Parses a string formatted in ISO-8601 format into a {DateTime} object.
    # @param string [String] The string to parse.
    # @param required [Boolean] Flag indicating if an error should be thrown when parsing fails.
    # @raise [Date::Error] when _required_ is `true` and an error occurs.
    def self.parse_date(string, required = true)
      begin
        return DateTime.iso8601(string)
      rescue Date::Error
        return nil unless required
        raise
      end
    end

    ##
    # Help method to convert a JSON array of "tags" into Ruby objects.
    # @param klass [Class] The class of the tag.
    # @param route [String] The relative endpoint to retrieve the tags.
    # @return [Array<Model>] the tags.
    def self.tags(klass, route)
      json = get(route)
      json&.map { |hash| klass.from_json(hash) }
    end

    ##
    # Updates the rate limit.
    #
    # @param response [::Net::HTTPResponse] The response object returned by the API call.
    # @return [void]
    def self.update_rates(response)
      if response.is_a?(::Net::HTTPResponse)
        @rate_limit = response['x_ratelimit_limit'].to_i
        @rate_remaining = response['x_ratelimit_remaining'].to_i
        @rate_reset = response['x_ratelimit_reset'].to_i
      end
    end

  end
end