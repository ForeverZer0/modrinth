# frozen_string_literal: true

require 'digest'

module Modrinth

  ##
  # Describes a specific version of a {Project} and its content.
  class Version

    ##
    # Describes dependencies of a specific version of a project.
    #
    # @attribute [r] version_id
    #   @return [String,nil] the ID of the version that this version depends on.
    # @attribute [r] project_id
    #   @return [String,nil] the ID of the project that this version depends on.
    # @attribute [r] filename
    #   @return [String] the file name of the dependency, mostly used for showing external dependencies on modpacks.
    # @attribute [r] type
    #   The type of dependency that this version has. Valid values include:
    #   * `:required`
    #   * `:optional`
    #   * `:incompatible`
    #   * `:embedded`
    #   @return [Symbol] the type of dependency that this version has.
    Dependency = Struct.new(:version_id, :project_id, :filename, :type)

    ##
    # Describes a resource file for a project.
    #
    # @attribute [r] sha1
    #   @return [String] the SHA1 hash for the file.
    # @attribute [r] sha256
    #   @return [String] the SHA256 hash for the file.
    # @attribute [r] url
    #   @return [String] a direct link to the file.
    # @attribute [r] filename
    #   @return [String] the name of the file.
    # @attribute [r] primary
    #   @return [Boolean] a flag indicating whether this is the primary file.
    # @attribute [r] size
    #   @return [Integer] the size of the file in bytes.
    # 
    File = Struct.new(:sha1, :sha256, :url, :filename, :primary, :size) do 

      ##
      # Downloads the file to the specified direcory and validates it checksum.
      #
      # @param directory [String] the output directory where the file will be written to.
      # @return [Integer] the number of bytes written.
      def download(directory = Dir.pwd)

        buffer = URI.open(self.url) { |io| io.read }
        if self.sha256
          sh1256 = Digest::SHA256.hexdigest(buffer)
          raise(SecurityError, 'SHA256 checksum failed') unless sha256 == self.sha256
        elsif self.sha1
          sha1 = Digest::SHA1.hexdigest(buffer)
          raise(SecurityError, 'SHA1 checksum failed') unless sha1 == self.sha1
        end

        path = ::File.join(directory, self.filename)
        ::File.write(path, buffer)
      end
    end

    ##
    # @return [String] the name of this version.
    attr_reader :name

    ##
    # @return [String] the version number. Ideally will follow semantic versioning.
    attr_reader :version_number

    ##
    # @return [String,nil] the changelog for this version.
    attr_reader :changelog

    ##
    # @return [Array<Dependency>] a list of specific versions of projects that this version depends on.
    attr_reader :dependencies

    ##
    # @return [Array<String>] a list of versions of Minecraft that this version supports.
    attr_reader :game_versions

    ##
    # The release channel for this version. Valid values include:
    # * `:release`
    # * `:beta`
    # * `:alpha`
    # @return [Symbol] the release channel for this version.
    attr_reader :version_type

    ##
    # @return [Array<String>] the mod loaders that this version supports.
    attr_reader :loaders

    ##
    # @return [Boolean] a flag indicating whether the version is featured or not.
    attr_reader :featured

    ##
    # @return [String] the ID of the version, encoded as a base62 string.
    attr_reader :id

    ##
    # @return [String] the ID of the project this version is for.
    attr_reader :project_id

    ##
    # @return [String] the ID of the author who published this version.
    attr_reader :author_id

    ##
    # @return [DateTime] the date the version was published.
    attr_reader :published

    ##
    # @return [Integer] the number of times this version has been downloaded.
    attr_reader :downloads

    ##
    # @return [Array<String>] a list of files available for download for this version.
    attr_reader :files

    ##
    # @api private
    # Initializes a new instance of the {Version} class.
    # @param params [Hash{Symbol,Object}] JSON objects representing the object.
    def initialize(**params)
      @name = params[:name]
      @version_number = params[:version_number]
      @changelog = params[:changelog]
      @game_versions = params[:game_versions]
      @version_type = params[:version_type].to_sym
      @loaders = params[:loaders]
      @featured = params[:featured]
      @id = params[:id]
      @project_id = params[:project_id]
      @author_id = params[:author_id]
      @published = DateTime.iso8601(params[:date_published])
      @downloads = params[:downloads]
      
      @files = Array.new
      if params[:files].is_a?(Array)
        params[:files].each do |hash|
          sha1 = hash[:hashes][:sha1]
          sha256 = hash[:hashes][:sha256]
          @files << File.new(sha1, sha256, hash[:url], hash[:filename], hash[:primary], hash[:size])
        end
      end

      @dependencies = Array.new
      if params[:dependencies].is_a?(Array)
        params[:dependencies].each do |hash|
          @dependencies << Dependency.new(hash[:version_id], hash[:project_id], hash[:file_name], hash[:dependency_type].to_sym)
        end
      end

    end

    ##
    # Downloads the file(s) associated with this version to the specified _directory_.
    # @param directory [String] The output directory where the file(s) will be saved.
    # @return [Integer] the number of files written.
    def download(directory = Dir.pwd)
      @files.count { |file| file.download(directory) > 0 }
    end
  end
end