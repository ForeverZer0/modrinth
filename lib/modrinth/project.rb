# frozen_string_literal: true

module Modrinth
  
  ##
  # Projects can be mods or modpacks and are created by users.
  class Project

    ##
    # Describes a gallery image that was uploaded to a {Project}.
    #
    # @attribute [r] url
    #   @return [String] the URL of the gallery image.
    # @attribute [r] featured
    #   @return [Boolean] a flag indicating whether the image is featured in the gallery.
    # @attribute [r] title
    #   @return [String,nil] the optional title of the gallery image.
    # @attribute [r] description
    #   @return [String,nil] the optional description of the gallery image.
    # @attribute [r] created
    #   @return [DateTime] the date and time the gallery image was created.
    # 
    Image = Struct.new(:url, :featured, :title, :description, :created)

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
    # @api private
    # Initializes a new instance of the {Project} class.
    # @param params [Hash{Symbol,Object}] JSON objects representing the object.
    def initialize(**params)
      @slug = params[:slug]
      @title = params[:title]
      @description = params[:description]
      @categories = params[:categories] || Array.new
      @client_side = params[:client_side]&.to_sym || :unsupported
      @server_side = params[:server_side]&.to_sym || :unsupported
      @body = params[:body]
      @type = params[:project_type]&.to_sym || :mod 
      @id = params[:id]
      @downloads = params[:downloads] || 0
      @icon_url = params[:icon_url]
      @followers = params[:followers] || 0
      @status = params[:status]&.to_sym || :unknown
      @published = DateTime.iso8601(params[:published]) if params.has_key?(:published)
      @approved = DateTime.iso8601(params[:approved]) if params.has_key?(:approved)
      @updated = DateTime.iso8601(params[:updated]) if params.has_key?(:updated)
      @versions = params[:versions] || Array.new
      self.license = params[:license] rescue License.new('custom', 'Custom License')
      @issues_url = params[:issues_url]
      @source_url = params[:source_url]
      @wiki_url = params[:wiki_url]
      @issues_url = params[:issues_url]
      @additional_categories = params[:additional_categories] || Array.new
      @team = params[:team]

      @donations = Array.new
      if params[:donation_urls]
        params[:donation_urls].each do |hash|
          @donations.push(DonationPlatform.new(hash[:id], hash[:name], hash[:url]))
        end
      end

      if params[:moderator_message]
        hash = params[:moderator_message]
        @moderator_message = ModeratorMessage.new(hash[:message], hash[:body])
      end

      @gallery = Array.new
      if params[:gallery]
        params[:gallery].each do |hash|
          date = DateTime.iso8601(hash[:created])
          @gallery << Image.new(hash[:url], hash[:featured], hash[:title], hash[:description], date)
        end
      end
    end

    ##
    # @!attribute [rw] slug
    #   @return [String] the slug of a project, used for vanity URLs.
    #   @see SLUG_PATTERN
    #   @raise [ArgumentError] when _value_ fails validation with the {SLUG_PATTERN} regular expression. 

    attr_reader :slug

    def slug=(value)
      unless Project::SLUG_PATTERN.match?(value)
        raise(ArgumentError, "slug must match regular expression \"#{Project::SLUG_PATTERN}\"")
      end
      @@slug = value
    end

    ##
    # @return [String] the title or name of the project.
    attr_accessor :title

    ##
    # @return [String] a short description of the project.
    attr_accessor :description

    ##
    # @return [Array<String>] a list of the categories that the project has.
    attr_reader :categories

    ##
    # @!attribute [rw] client_side
    #   A {Symbol} describing the the client side support of the project.
    #   @return [Symbol] the client-side support value.
    #   @see server_side
    #   @see SUPPORT
    #   @raise [ArgumentError] when _support_ is not a valid value defined in {SUPPORT}.


    attr_reader :client_side

    def client_side=(support)
      @client_side = assert_support(support)
    end

    ##
    # @!attribute [rw] server_side
    #   A {Symbol} describing the the server side support of the project.
    #   @return [Symbol] the server-side support value.
    #   @see client_side
    #   @see SUPPORT
    #   @raise [ArgumentError] when _support_ is not a valid value defined in {SUPPORT}.


    attr_reader :server_side

    def server_side=(support)
      @server_side = assert_support(support)
    end


    ##
    # @return [String] the long form description of the project.
    attr_accessor :body

    ##
    # @!attribute [rw] type
    #   @return [Symbol] the project type of the project.
    #   @see TYPES
    #   @raise [ArgumentError] when _type_ is not a valid value defined in {TYPES}.
    

    attr_reader :type

    def type=(type)
      @type = type.to_sym
      unless Project::TYPES.include?(@type)
        expected = Project::TYPES.join(', ')
        raise(ArgumentError, "invalid project type specified (given #{@type}, expected #{expected})")
      end
      type
    end

    ##
    # @return [Integer] the total number of downloads of the project.
    attr_reader :downloads

    ##
    # @return [String] the ID of the project, encoded as a base62 string.
    attr_reader :id

    ##
    # @return [String,nil] the URL of the project's icon.
    attr_reader :icon_url
    
    ##
    # @return [Integer] the total number of users following the project.
    attr_reader :followers
 
    ##
    # @return [Symbol] the status of the project.
    # @see STATUS
    attr_reader :status

    ##
    # @return [DateTime] the date the project was published.
    attr_reader :published

    ##
    # @return [DateTime] the date the project was last updated.
    attr_reader :updated

    ##
    # @return [DateTime] the date the project's status was set to approved or unlisted.
    attr_reader :approved

    ##
    # @return [Array<String>] a list of the version IDs of the project (will never be empty unless `draft` status).
    attr_reader :versions

    ##
    # @!attribute [rw] license
    #   @return [License,String] the license of the project.
    #   @note When a {String} is supplied, a license with a matching ID or name is searched for.
    #   @raise [ArgumentError] when an invalid/undefined license is specified.
    #   @see Modrinth.licenses


    attr_reader :license

    def license=(value)
      if value.is_a?(String)
        value = Modrinth.licenses.find { |license| license.id == value || license.name == value }
      elsif value.is_a?(Hash)
        value = License.new(value[:id], value[:name], value[:url])
      end
      raise(ArgumentError, "unknown license specified") unless value.is_a?(License)
      @license = license
    end

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
    attr_reader :donations

    ##
    # @return [ModeratorMessage,nil] a message that a moderator sent regarding the project.
    attr_reader :moderator_message

    ##
    # @return [Array<Array<String>>] a list of categories which are searchable but non-primary.
    attr_reader :additional_categories

    ##
    # @return [String] the ID of the team that has ownership of this project.
    attr_accessor :team

    ##
    # @return [Array<Project::Image>] a list of images that have been uploaded to the project's gallery.
    attr_reader :gallery

    private

    ##
    # Asserts a the specified support _value_ is valid and returns it as a {Symbol}.
    #
    # @param value [Symbol,String] The value to validate.
    # @return [Symbol] the value as a Symbol.
    # @raise [ArgumentError] when _value_ is invalid.
    def assert_support(value)
      support = value.to_sym
      unless Project::SUPPORT.include?(support)
        expected = Project::SUPPORT.join(', ')
        raise(ArgumentError, "invalid support type specified (given #{support}, expected #{expected})")
      end
      support
    end
  end

end