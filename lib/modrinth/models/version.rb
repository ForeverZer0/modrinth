# frozen_string_literal: true

module Modrinth

  ##
  # Describes a specific version of a {Project} and its content.
  class Version < Model

    ##
    # Describes dependencies of a specific version of a project.
    class Dependency < Model

      ##
      # An array containing the valid dependency type values.
      # @return [Array<Symbol>]
      TYPES = %i(required optional incompatible embedded).freeze

      ##
      # @return [String,nil] the ID of the version that this version depends on.
      attr_accessor :version_id

      ##
      # @return [String,nil] the ID of the project that this version depends on.
      attr_accessor :project_id

      ##
      # @return [String] the file name of the dependency, mostly used for showing external dependencies on modpacks.
      attr_accessor :filename

      ##
      # The type of dependency that this version has. See {TYPES} for valid values.
      #
      # @return [Symbol] the type of dependency that this version has.
      # @see TYPES
      attr_accessor :type

      ##
      # Creates a new instance from a JSON object.
      # @param json [Hash{Symbol,Object}] A {Hash} representing the JSON object.
      # @return [Version::Dependency] the newly created instance.
      def self.from_json(json)
        dependency = allocate
        dependency.version_id = json[:version_id]
        dependency.project_id = json[:project_id]
        dependency.filename = json[:file_name] || json[:filename]
        dependency.type = json[:dependency_type].to_sym
        dependency
      end

      ##
      # (see Model#to_h)
      def to_h
        { version_id: @verions_id, project_id: @project_id, file_name: @filename, dependency_type: @type }.compact
      end
    end

    ##
    # Describes a resource file for a project.
    class Resource < Model

      ##
      # @return [String] the SHA1 hash for the file.
      attr_accessor :sha1

      ##
      # @return [String] the SHA256 hash for the file.
      attr_accessor :sha256

      ##
      # @return [String] a direct link to the file.
      attr_accessor :url

      ##
      # @return [String] the name of the file.
      attr_accessor :filename

      ##
      # A flag indicating whether this is the primary file.
      # @return [Boolean] `true` if the primary file, otherwise `false`.
      attr_accessor :primary

      ##
      # @return [Integer] the size of the file in bytes.
      attr_accessor :size

      ##
      # Creates a new instance from a JSON object.
      # @param json [Hash{Symbol,Object}] A {Hash} representing the JSON object.
      # @return [Version::Resource] the newly created instance.
      def self.from_json(json)

        resource = allocate
        if json[:hashes].is_a?(Hash)
          resource.sha1 = json[:hashes][:sha1]
          resource.sha256 = json[:hashes][:sha256]
        end 
        
        resource.url = hash[:url]
        resource.filename = hash[:filename] || hash[:file_name]
        resource.primary = !!hash[:primary]
        resource.size = hash[:size]
        resource
      end

      ##
      # (see Model#to_h)
      def to_h
        hashes = { sha1: @sha1, sha256: @sha256}.compact
        { hashes: hashes, url: @url, filename: @filename, primary: @primary, size: @size }.compact
      end

      ##
      # Downloads the file to the specified direcory and validates it checksum.
      #
      # @param directory [String] the output directory where the file will be written to.
      # @return [Integer] the number of bytes written.
      # @raise [SecurityError] when the checksum fails on the downloaded content.
      def download(directory = Dir.pwd, checksum = true)
        buffer = URI.open(self.url) { |io| io.read }
        assert_checksum(buffer) if checksum
        path = File.join(directory, self.filename)
        File.write(path, buffer)
      end

      private

      ##
      # Asserts the downloaded content checksum is valid.
      # @param buffer [String] A binary buffer containing the value perform the checksum on.
      # @return [void]
      # @raise [SecurityError] when the checksum fails.
      def assert_checksum(buffer)
        if @sha256
          sh1256 = Digest::SHA256.hexdigest(buffer)
          raise(SecurityError, 'SHA256 checksum failed') unless sha256 == @sha256
          return
        end

        return unless @sha1
        sha1 = Digest::SHA1.hexdigest(buffer)
        raise(SecurityError, 'SHA1 checksum failed') unless sha1 == @sha1
      end
    end

    ##
    # @return [String] the name of this version.
    attr_accessor :name

    ##
    # @return [String] the version number. Ideally will follow semantic versioning.
    attr_accessor :version_number

    ##
    # @return [String,nil] the changelog for this version.
    attr_accessor :changelog

    ##
    # @return [Array<Dependency>] a list of specific versions of projects that this version depends on.
    attr_accessor :dependencies

    ##
    # @return [Array<GameVersion>] a list of versions of Minecraft that this version supports.
    attr_accessor :game_versions

    ##
    # The release channel for this version. Valid values include:
    # * `:release`
    # * `:beta`
    # * `:alpha`
    # @return [Symbol] the release channel for this version.
    attr_accessor :version_type

    ##
    # @return [Array<Loader>] the mod loaders that this version supports.
    attr_accessor :loaders

    ##
    # @return [Boolean] a flag indicating whether the version is featured or not.
    attr_accessor :featured

    ##
    # @return [String] the ID of the version, encoded as a base62 string.
    attr_accessor :id

    ##
    # @return [String] the ID of the project this version is for.
    attr_accessor :project_id

    ##
    # @return [String] the ID of the author who published this version.
    attr_accessor :author_id

    ##
    # @return [DateTime] the date the version was published.
    attr_accessor :published

    ##
    # @return [Integer] the number of times this version has been downloaded.
    attr_accessor :downloads

    ##
    # @return [Array<String>] a list of files available for download for this version.
    attr_accessor :files

    ##
    # Creates a new instance from a JSON object.
    # @param json [Hash{Symbol,Object}] A {Hash} representing the JSON object.
    # @return [Version] the newly created instance.
    def self.from_json(json)

      version = allocate
      %i(name version_number changelog loaders featured id project_id author_id downloads).each do |sym|
        version.instance_variable_set("@#{sym}".to_sym, params[sym])
      end

      version.game_versions = json[:game_versions]&.map { |str| GameVersion.from_name(str) } || Array.new
      version.loaders = json[:loaders]&.map { |str| Loader.from_name(str) } || Array.new
      version.version_type = params[:version_type].to_sym
      version.published = Modrinth::Net.parse_date(params[:date_published])
      version.files = params[:files]&.map { |hash| Resource.from_json(hash) } || Array.new
      version.dependencies = params[:dependencies]&.map { |hash| Dependency.from_json(hash) } || Array.new
      version
    end

    ##
    # (see Model#to_h)
    def to_h
      hash = 
      {
        game_versions: @game_versions.map(&:version),
        loaders: @loaders.map(&:name),
        date_published: @published.iso8601,
        files: @files.map(&:to_h),
        dependencies: @dependencies.map(&:to_h)
      }
      %i(name version_number changelog loaders featured id project_id author_id downloads version_type).each do |sym|
        hash[sym] = instance_variable_get("@#{sym}")
      end
      hash
    end

    ##
    # Downloads the file(s) associated with this version to the specified _directory_.
    # @param directory [String] The output directory where the file(s) will be saved.
    # @return [Integer] the number of files written.
    def download(directory = Dir.pwd, primary_only = false)

      if primary_only
        primary = @files.find { |resource| resource.primary }
        return 0 unless primary
        return primary.download(directory).zero? ? 0 : 1
      end

      @files.count { |file| file.download(directory) > 0 }
    end
  end
end