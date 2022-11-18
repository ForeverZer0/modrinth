# frozen_string_literal: true

require_relative 'user'

module Modrinth

  ##
  # Describes a {User} who is a member of a team.
  class TeamMember < User

    ##
    # Default permission value indicating no permissions.
    # @return [Integer]
    NO_PERMISSION   = 0x00

    ##
    # Permission but indicating user has all permissions.
    # @return [Integer]
    ALL_PERMISSIONS = 0xFF

    ##
    # Permission bit indicating user can upload project versions.
    # @return [Integer]
    UPLOAD_VERSION  = 0x01

    ##
    # Permission bit indicating user can delete project versions.
    # @return [Integer]
    DELETE_VERSION  = 0x02

    ##
    # Permission bit indicating user can edit project details.
    # @return [Integer]
    EDIT_DETAILS    = 0x04

    ##
    # Permission bit indicating user can edit project descriptions.
    # @return [Integer]
    EDIT_BODY       = 0x08

    ##
    # Permission bit indicating user can manage invites.
    # @return [Integer]
    MANAGE_INVITES  = 0x10

    ##
    # Permission bit indicating user can remove members.
    # @return [Integer]
    REMOVE_MEMBER   = 0x20

    ##
    # Permission bit indicating user can edit members.
    # @return [Integer]
    EDIT_MEMBER     = 0x40

    ##
    # Permission bit indicating user can delete projects.
    # @return [Integer]
    DELETE_PROJECT  = 0x80

    ##
    # @return [String] the ID of the team this team member is a member of.
    attr_accessor :team_id

    ##
    # @return [Symbol] the user's role on the team.
    attr_accessor :team_role

    ##
    # Flag indicating whether or not the user has accepted to be on the team (requires authorization to view).
    # @return [Boolean,nil] `true` if user has been accepted, `false` if not, otherwise `nil` if unable to view.
    attr_accessor :accepted

    ##
    # The user's permissions in bitfield format (requires authorization to view).
    #
    # In order from first to eighth bit, the bits are:
    # * {UPLOAD_VERSION}
    # * {DELETE_VERSION}
    # * {EDIT_DETAILS}
    # * {EDIT_BODY}
    # * {MANAGE_INVITES}
    # * {REMOVE_MEMBER}
    # * {EDIT_MEMBER}
    # * {DELETE_PROJECT}
    #
    # @return [Integer,nil] the permission bits, or {NO_PERMISSION} if unable to view.
    attr_accessor :permissions

    ##
    # Checks if the specified permission _bit_ is set.
    # @param bit [Integer] the permission bit to query. Valid values include:
    #   * {UPLOAD_VERSION}
    #   * {DELETE_VERSION}
    #   * {EDIT_DETAILS}
    #   * {EDIT_BODY}
    #   * {MANAGE_INVITES}
    #   * {REMOVE_MEMBER}
    #   * {EDIT_MEMBER}
    #   * {DELETE_PROJECT}
    # @return [Boolean] `true` if user has permission, otherwise `false` if not or unable to query permissions.
    def permission?(bit)
      (@permissions & bit).nonzero?
    end

    ##
    # Creates a new instance from a JSON object.
    # @param json [Hash{Symbol,Object}] A {Hash} representing the JSON object.
    # @return [TeamMember] the newly created instance.
    def self.from_json(json)
      member = super(json[:user])
      member.team_role = json[:role].to_sym
      member.permissions = json[:permissions] || NO_PERMISSION
      member.accepted = json[:accepted]
      member
    end
  end
end