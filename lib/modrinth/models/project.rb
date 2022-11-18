# frozen_string_literal: true

module Modrinth
  
  ##
  # Projects can be mods or modpacks and are created by users.
  class Project < Model

    ##
    # Describes a gallery image that was uploaded to a {Project}.
    class Image < Model

      ##
      # @return [String] the URL of the gallery image.
      attr_accessor :url

      ##
      # A flag indicating whether the image is featured in the gallery.
      # @return [Boolean] `true` if the image is featured, otherwise `false`.
      attr_accessor :featured

      ##
      # @return [String,nil] the optional title of the gallery image.
      attr_accessor :title

      ##
      # @return [String,nil] the optional description of the gallery image.
      attr_accessor :description

      ##
      # @return [DateTime] the date and time the gallery image was created.
      attr_accessor :created

      ##
      # Creates a new instance from a JSON object.
      # @param json [Hash{Symbol,Object}] A {Hash} representing the JSON object.
      # @return [Project::Image] the newly created instance.
      def self.from_json(json)
        img = allocate
        %i(url featured title description).each { |sym| img.instance_variable_set("@#{sym}", json[sym]) }
        img.created = Modrinth::Net.parse_date(json[:created])
        img
      end
    end

    ##
    # The regular expression for validating strings used as slugs.
    # @return [Regexp] the regular expression used for validation.
    SLUG_PATTERN = /^[\w!@$()`.+,"\-']{3,64}$/

    ##
    # Array containing the possible values describing a project type.
    # @return [Array<Symbol>] the project types.
    TYPES = %i(mod modpack resourcepack)

    ##
    # Array containing the possible values describing client/server support.
    # @return [Array<Symbol>] the support types.
    SUPPORT = %i(required optional unsupported)

    ##
    # Array containing the possibls values describing the status of a project.
    # @return [Array<Symbol>] the status values.
    STATUS = %i(approved rejected draft unlisted archived processing unknown)

    ##
    # @return [String] the slug of a project, used for vanity URLs.
    # @see SLUG_PATTERN
    attr_accessor :slug

    ##
    # @return [String] the title or name of the project.
    attr_accessor :title

    ##
    # @return [String] a short description of the project.
    attr_accessor :description

    ##
    # @return [Array<String>] a list of the categories that the project has.
    attr_accessor :categories

    ##
    # A {Symbol} describing the the client side support of the project.
    # @return [Symbol] the client-side support value.
    # @see server_side
    # @see SUPPORT
    attr_accessor :client_side

    ##
    # A {Symbol} describing the the server side support of the project.
    # @return [Symbol] the server-side support value.
    # @see client_side
    # @see SUPPORT
    attr_accessor :server_side

    ##
    # @return [String] the long form description of the project.
    attr_accessor :body

    ##
    # @return [Symbol] the project type of the project.
    # @see TYPES
    attr_accessor :type

    ##
    # @return [Integer] the total number of downloads of the project.
    attr_accessor :downloads

    ##
    # @return [String] the ID of the project, encoded as a base62 string.
    attr_accessor :id

    ##
    # @return [String,nil] the URL of the project's icon.
    attr_accessor :icon_url
    
    ##
    # @return [Integer] the total number of users following the project.
    attr_accessor :followers
 
    ##
    # @return [Symbol] the status of the project.
    # @see STATUS
    attr_accessor :status

    ##
    # @return [DateTime] the date the project was published.
    attr_accessor :published

    ##
    # @return [DateTime] the date the project was last updated.
    attr_accessor :updated

    ##
    # The date the project's status was set to approved or unlisted.
    # @return [DateTime,nil] the approval date, or `nil` if no approvale has been made.
    attr_accessor :approved

    ##
    # @return [Array<String>] a list of the version IDs of the project (will never be empty unless `draft` status).
    attr_accessor :versions

    ##
    # @return [License,String] the license of the project.
    # @see Modrinth.licenses
    attr_accessor :license

    ##
    # @return [String,nil] an optional link to where to submit bugs or issues with the project.
    attr_accessor :issues_url

    ##
    # @return [String,nil] an optional link to the source code of the project.
    attr_accessor :source_url

    ##
    # @return [String,nil] an optional link to the project's wiki page or other relevant information.
    attr_accessor :wiki_url

    ##
    # @return [String,nil] an optional invite link to the project's Discord.
    attr_accessor :issues_url

    ##
    # @return [Array<DonationPlatform>] a list of donation links for the project.
    attr_accessor :donations

    ##
    # @return [ModeratorMessage,nil] a message that a moderator sent regarding the project.
    attr_accessor :moderator_message

    ##
    # @return [Array<Array<String>>] a list of categories which are searchable but non-primary.
    attr_accessor :additional_categories

    ##
    # @return [String] the ID of the team that has ownership of this project.
    attr_accessor :team

    ##
    # @return [Array<Project::Image>] a list of images that have been uploaded to the project's gallery.
    attr_accessor :gallery

    ##
    # 
    # @overload each_version(&block)
    #   @yieldparam version [Version] A {Version} associated with this project.
    #   @return [void]
    #
    # @overload each_version
    #   @return [Enumerator]
    def each_version
      return enum_for(__method__) unless block_given?

      
    end


    ##
    # Creates a new instance from a JSON object.
    # @param json [Hash{Symbol,Object}] A {Hash} representing the JSON object.
    # @return [Project] the newly created instance.
    def self.from_json(json)

      project = allocate
      %i(slug title description body id icon_url issues_url source_url wiki_url).each do |sym|
        project.instance_variable_set("@#{sym}", json[sym])
      end
  
      project.categories = json[:categories] || Array.new
      project.client_side = json[:client_side]&.to_sym || :unsupported
      project.server_side = json[:server_side]&.to_sym || :unsupported
      project.type = json[:project_type]&.to_sym || :mod     
      project.status = json[:status]&.to_sym || :unknown


      project.versions = json[:versions] || Array.new
      project.license = License.from_json(json[:license]) rescue nil
      project.additional_categories = json[:additional_categories] || Array.new
      project.team = json[:team]

      project.downloads = json[:downloads] || 0
      project.followers = json[:followers] || 0
      project.published = Modrinth::Net.parse_date(json[:published])
      project.approved = Modrinth::Net.parse_date(json[:approved], false)
      project.updated = Modrinth::Net.parse_date(json[:updated])

      if json[:moderator_message].is_a?(Hash)
        project.moderator_message = ModeratorMessage.from_json(json[:moderator_message])
      end

      project.donations = json[:donation_urls]&.map { |hash| DonationPlatform.from_json(hash) } || Array.new
      project.gallery = json[:gallery]&.map { |hash| Image.from_json(hash) } || Array.new
      project
    end

  end
end