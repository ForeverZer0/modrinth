# frozen_string_literal: true

module Modrinth

  ##
  # Describes Minecraft game versions.
  # @see Modrinth.game_versions
  class GameVersion < Model

    ##
    # Array containing list of valid Minecraft version types.
    # @return [Array<Symbol>]
    TYPES = %i(release snapshot alpha beta).freeze

    ##
    # @return [String] the name/number of the game version.
    attr_accessor :version

    ##
    # @return [Symbol] the type of the game version.
    # @note See {TYPES} array for valid values.
    # @see TYPES
    attr_accessor :version_type

    ##
    # @return [DateTime,String] the date of the game version release.
    attr_accessor :date

    ##
    # @return [Boolean] flag indicating whether or not this is a major version, used for _Featured Versions_.
    attr_accessor :major

    ##
    # Initializes a new instance of the {GameVersion} class.
    # @param version [String] The name/number of the game version.
    # @param version_type [Symbol,String] The type of the game version.
    # @param date [DateTime,String] The date of the game version release. When a {String} is specified,
    #   it must be in [ISO-8601](https://en.wikipedia.org/wiki/ISO_8601) format.
    # @param major [Boolean] Flag indicating whether or not this is a major version.
    def initialize(version, version_type, date, major)
      @version = version.to_s
      @version_type = version_type.to_sym
      @major = !!major
      @date = date.is_a?(String) ? DateTime.iso8601(date) : date
    end

    ##
    # Attempts to parse a {GameVersion} instance from the specified string.
    #
    # @example
    #   p GameVersion.from_name('1.19.2')
    #   #<Modrinth::GameVersion:0x000055efba20a0f8 @version="1.19.2", @version_type=:release, @major=true, @date=#<DateTime: 2022-08-05T11:57:05+00:00 ((2459797j,43025s,0n),+0s,2299161j)>>
    #
    # @param name [String] A string containing the name of the Minecraft version.
    # @return [GameVersion,nil] the newly created instance if successful, otherwise `nil`.
    # @note The search is case-insensitive.
    def self.from_name(name)
      return nil unless name.is_a?(String)
      Modrinth.game_versions.find { |gv| gv.version.casecmp(name).zero? }
    end

    ##
    # Creates a new instance from a JSON object.
    # @param json [Hash{Symbol,Object}] A {Hash} representing the JSON object.
    # @return [GameVersion] the newly created instance.
    def self.from_json(json)
      new(json[:version], json[:version_type], json[:date], json[:major])
    end

    ##
    # (see Model#to_h)
    def to_h
      { version: @version, version_type: @version_type, date: @date.iso8601, major: @major }.compact
    end

    ##
    # (see Model#to_s)
    def to_s
      "#{version} (#{@version_type.to_s.capitalize})"
    end
  end
end