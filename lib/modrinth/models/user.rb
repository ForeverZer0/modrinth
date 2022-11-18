# frozen_string_literal: true

module Modrinth

  ##
  # Describes a registered Modrinth user and their role.
  class User < Model

    ##
    # Array containing values for valid roles.
    # @return [Array<Symbol>]
    ROLES = %i(admin moderator developer).freeze

    ##
    # @return [String] the user's username.
    attr_accessor :username

    ##
    # @return [String,nil] the user's display name.
    attr_accessor :name

    ##
    # @return [String,nil] the user's email (only your own is ever displayed).
    attr_accessor :email

    ##
    # @return [String,nil] a description of the user.
    attr_accessor :bio

    ##
    # @return [String,nil] the user's ID.
    attr_accessor :id

    ##
    # @return [String,nil] the user's GitHub ID. 
    attr_accessor :github_id

    ##
    # @return [String,nil] the user's avatar URL.
    attr_accessor :avatar_url

    ##
    # @return [DateTime] the time at which the user was created.
    attr_accessor :created

    ##
    # The user's role. See {ROLES} for valid values.
    # @return [Symbol] the user's role. 
    # @see ROLES
    attr_accessor :role

    ##
    # Creates a new instance from a JSON object.
    # @param json [Hash{Symbol,Object}] A {Hash} representing the JSON object.
    # @return [User] the newly created instance.
    def self.from_json(json)
      user = allocate
      %i(username name email bio id github_id avatar_url).each do |sym|
        user.instance_variable_set("@#{sym}".to_sym, json[sym])
      end
      user.created = Modrinth::Net.parse_date(json[:created])
      user.role = json[:role].to_sym
      user
    end

    ##
    # (see Model#to_h)
    def to_h
      hash = super
      hash[:created] = @created.iso8601
      hash.compact
    end
  end
end