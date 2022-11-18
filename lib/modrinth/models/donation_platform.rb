# frozen_string_literal: true

module Modrinth

  ##
  # Describes a platform where project owners/developers can accept monetary donations for their contribution.
  # @see Modrinth.donation_platforms
  class DonationPlatform < Model

    ##
    # @return [String] the short identifier of the donation platform.
    attr_accessor :id

    ##
    # @return [String] the full name of the donation platform.
    attr_accessor :name

    ##
    # @return [String,nil] the optional URL to the donation platform.
    attr_accessor :url

    ##
    # Initializes a new instance of the {DonationPlatform} class.
    # @param id [String] The short identifier of the donation platform.
    # @param name [String] The full name of the donation platform.
    # @param url [String] The optional URL to the donation platform.
    def initialize(id, name, url = nil)
      @id = id
      @name = name
      @url = url
    end

    ##
    # Compares _other_ object for equality to this instance.
    # @param other [Object,nil] The object to compare for equality.
    # @return [Boolean] `true` if _other_ is a {DonationPlatform} with the same ID and URL, otherwise `false`.
    def ==(other)
      other.is_a?(License) && other.id == @id && @url == other.url
    end

    alias_method :eql?, :==

    ##
    # (see Model#to_s)
    def to_s
      @url ? "#{name} (#{@url})" : @name
    end

    ##
    # Creates a new instance from a JSON object.
    # @param json [Hash{Symbol,Object}] A {Hash} representing the JSON object.
    # @return [DonationPlatform] the newly created instance.
    def self.from_json(json)
      new(json[:id] || json[:short], json[:name], json[:url])
    end

    ##
    # Convenience method to create a {DonationPlatform} with a [Patreon](https://www.patreon.com/) URL.
    # @param url [String] The URL where donations can be made.
    # @return [DonationPlatform] the newly created {DonationPlatform} instance.
    def self.patreon(url)
      new('patreon', 'Patreon', url)
    end

    ##
    # Convenience method to create a {DonationPlatform} with a [Buy Me a Coffee](https://www.buymeacoffee.com/) URL.
    # @param url [String] The URL where donations can be made.
    # @return [DonationPlatform] the newly created {DonationPlatform} instance.
    def self.bmac(url)
      new('bmac', 'Buy Me a Coffee', url)
    end

    ##
    # Convenience method to create a {DonationPlatform} with a [PayPal](https://www.paypal.com/) URL.
    # @param url [String] The URL where donations can be made.
    # @return [DonationPlatform] the newly created {DonationPlatform} instance.
    def self.paypal(url)
      new('paypal', 'PayPal', url)
    end

    ##
    # Convenience method to create a {DonationPlatform} with a [GitHub Sponsors](https://github.com/sponsors) URL.
    # @param url [String] The URL where donations can be made.
    # @return [DonationPlatform] the newly created {DonationPlatform} instance.
    def self.github(url)
      new('github', 'GitHub Sponsors', url)
    end

    ##
    # Convenience method to create a {DonationPlatform} with a [Ko-fi](https://ko-fi.com/) URL.
    # @param url [String] The URL where donations can be made.
    # @return [DonationPlatform] the newly created {DonationPlatform} instance.
    def self.kofi(url)
      new('ko-fi', 'Ko-fi', url)
    end
  end
end