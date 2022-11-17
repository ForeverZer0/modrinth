# frozen_string_literal: true

require 'net/http'

module Modrinth

  ##
  # @api private
  # Utility module provideing methods for interacting with the remote Modrinth API.
  module Net

    ##
    # Describes the rate-limit for calls to the Modrinth API.
    # 
    # @note The rate limit for all users of the API is currently `300` per minute. 
    #   If you have a use case requiring a higher limit, please [contact Modrinth](mailto:admin@modrinth.com).
    #
    # @attribute [r] limit 
    #   @return [Integer] the maximum number of requests that can be made in a minute.
    # @attribute [r] remaining
    #   @return [Integer] the number of requests remaining in the current ratelimit window.
    # @attribute [r] reset 
    #   @return [Integer] the time in seconds until the ratelimit window resets.
    RateLimit = Struct.new(:limit, :remaining, :reset)

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
    BASE_URL = 'https://api.modrinth.com/v2'

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
    # @param params [Hash] A hash containing the REST query.
    #
    # @note The rate limit is tracked internally and updated with each call from the response headers.
    # @return [Hash{Symbol,Object},nil] the JSON response, or `nil` if a non-successful response was returned.
    def self.get(method, params = nil)

      uri = URI(BASE_URL + method)
      uri.query = URI.encode_www_form(params) if params

      response = ::Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        request = ::Net::HTTP::Get.new(uri.to_s, HEADERS)
        http.request(request)
      end

      return nil unless response.is_a?(::Net::HTTPSuccess)
      update_rates(response)
      JSON.parse(response.body, symbolize_names: true)
    end

    ##
    # Executes a POST request with the given parameters.
    # @param method [String] The remote endpoint for the method to call.
    # @param params [Hash] A hash containing the REST query.
    # @param payload [Hash] A hash containing the JSON payload defining the message body.
    #
    # @note The rate limit is tracked internally and updated with each call from the response headers.
    # @return [Hash{Symbol,Object},nil] the JSON response, or `nil` if a non-successful response was returned.
    def self.post(method, params, payload)

      uri = URI(BASE_URL + method)
      uri.query = URI.encode_www_form(params)
      response = ::Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        request = ::Net::HTTP::Post.new(uri, HEADERS)
        request.content_type = 'application/json'
        request.body = payload.to_json
        http.request(request)
      end

      return nil unless response.is_a?(::Net::HTTPSuccess)
      update_rates(response)
      JSON.parse(response.body, symbolize_names: true)
    end

    private

    ##
    # Updates the rate limit.
    #
    # @param response [::Net::HTTPResponse] The response object returned by the API call.
    # @return [void]
    def self.update_rates(response)
      args = %w(x_ratelimit_limit x_ratelimit_remaining x_ratelimit_reset)
      @rate_limit = RateLimit.new(*args.map { |arg| response[arg].to_i})
    end

  end
end