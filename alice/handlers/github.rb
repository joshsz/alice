module Handlers
  class GitHub

    include PoroPlus
    include Behavior::HandlesCommands

    def issues
      message.set_response(parser.issues.take(5).join("\n"))
    end

    def commits
      message.set_response(parser.commits.take(5).join("\n"))
    end

    def contributors
      message.set_response("My contributors include #{parser.contributors.to_sentence}.")
    end

    private

    def parser
      Parser::GitHub.fetch
    end

  end
end

