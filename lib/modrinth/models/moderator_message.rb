# frozen_string_literal: true

module Modrinth

  ##
  # Describes a moderator message.
  class ModeratorMessage < Model

    ##
    # @return [String] the message that a moderator has left for the project.
    attr_accessor :message

    ##
    # @return [String,nil] the longer body of the message that a moderator has left for the project.
    attr_accessor :body

    ##
    # @param message [String] The message that a moderator has left for the project.
    # @param body [String,nil] The longer body of the message that a moderator has left for the project.
    # @raise [ArgumentError] when _message_ is `nil`.
    def initialize(message, body)
      @message = message || raise(ArgumentError, 'message cannot be nil')
      @body = body
    end

    ##
    # (see Model#to_s)
    def to_s
      @message
    end
  end
end