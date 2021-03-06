require 'spec_helper'

describe "Parser::Mash" do

  before do
    User.destroy_all
    Item.destroy_all
    Factoid.destroy_all
    @robyn  = ::User.create!(primary_nick: "robyn")
    @syd    = ::User.create!(primary_nick: "syd")
    @tomato = Item.create!(name: "tomato")
    @command = Message::Command.find_or_create_by(
      name: "get_fact",
      indicators: ["know", "fact", "factoid", "tell"],
      handler_class: "Handlers::Factoid",
      handler_method: "get"
    )
    Message::Command.find_or_create_by(
      name: "properties",
      verbs: ["can_brew?", "can_forge?", "last_seen", "can_play_game?", "current_nick", "dazed?", "disoriented?", "drunk?", "is_online?", "is_op?", "bio", "proper_name", "twitter_handle", "twitter_url", "points", "check_points", "check_score"],
      stop_words: [],
      indicators: ["can_brew?", "can_forge?", "last_seen", "can_play_game?", "current_nick", "dazed?", "disoriented?", "drunk?", "is_online?", "is_op?", "bio", "proper_name", "twitter_handle", "twitter_url"],
      handler_class: "Handlers::Properties",
      handler_method: "get_property"
    )
    @factoid = Factoid.create!(user: @robyn, text: "Briggs features in the Robyn Hitchcock song 'A Man\'s Gotta Know'")
  end

  context "Alice, say hello to Syd" do

    let(:command_string)  { Message::CommandString.new("#{ENV['BOT_NAME']}, say hello to Syd.") }
    let(:parser)          { Parser::Mash.new(command_string) }

    before do
      parser.parse
    end

    it "recognizes Syd" do
      expect(parser.subject).to eq(@syd)
    end

  end

  context "Alice, what do you know about Robyn?" do

    let(:command_string)  { Message::CommandString.new("#{ENV['BOT_NAME']}, what do you know about Robyn?") }
    let(:parser)          { Parser::Mash.new(command_string) }

    before do
      parser.parse
    end

    it "recognizes Robyn" do
      expect(parser.subject).to eq(@robyn)
    end

    it "recognizes factoids" do
      expect(parser.command).to eq(@command)
    end

  end

  context "Alice, please give the tomato to Robyn." do

    let(:command_string)  { Message::CommandString.new("#{ENV['BOT_NAME']}, please give the tomato to Robyn.") }
    let(:parser)          { Parser::Mash.new(command_string) }

    before do
      parser.parse
    end

    it "recognizes the tomato object" do
      expect(parser.object).to eq(@tomato)
    end

    it "recognizes the Robyn user" do
      expect(parser.subject).to eq(@robyn)
    end

  end

  context "Alice, please give Robyn the tomato." do

    let(:command_string)  { Message::CommandString.new("#{ENV['BOT_NAME']}, please give Robyn the tomato.") }
    let(:parser)          { Parser::Mash.new(command_string) }

    before do
      parser.parse
    end

    it "recognizes the tomato object" do
      expect(parser.object).to eq(@tomato)
    end

    it "recognizes the Robyn user" do
      expect(parser.subject).to eq(@robyn)
    end

  end

  context "Alice, who is Syd?" do

    let(:command_string)  { Message::CommandString.new("#{ENV['BOT_NAME']}, who is Syd?") }
    let(:parser)          { Parser::Mash.new(command_string) }

    before do
      parser.parse
    end

    it "recognizes the Syd user" do
      expect(parser.subject).to eq(@syd)
    end

  end

  context "Alice, what is Syd's twitter handle?" do

    context "happy path" do

      let(:command_string)  { Message::CommandString.new("#{ENV['BOT_NAME']}, what is Syd's twitter handle?") }
      let(:parser)          { Parser::Mash.new(command_string) }

      before do
        parser.parse
      end

      it "recognizes the Syd user" do
        expect(parser.subject).to eq(@syd)
      end

      it "maps the object to a whitelisted instance method" do
        expect(parser.property).to eq :twitter_handle
      end

    end

    context "edge cases" do

      let(:command_string)  { Message::CommandString.new("#{ENV['BOT_NAME']}, what is Syd's destroy?") }
      let(:parser)          { Parser::Mash.new(command_string) }

      before do
        parser.parse
      end

      it "does not map to a non-whitelisted instance method" do
        expect(parser.property).to be_nil
      end

    end

  end

  context "Alice, who made the tomato?" do

    let(:command_string)  { Message::CommandString.new("#{ENV['BOT_NAME']}, who made the tomato?") }
    let(:parser)          { Parser::Mash.new(command_string) }

    before do
      parser.parse
    end

    it "recognizes the tomato object" do
      expect(parser.object).to eq(@tomato)
    end

    it "maps to the object's creator method" do
      expect(parser.property).to eq(:made_by)
    end

  end

  context "Alice, how many points does Robyn have?" do

    let(:command_string)  { Message::CommandString.new("#{ENV['BOT_NAME']}, how many points does Robyn have?") }
    let(:parser)          { Parser::Mash.new(command_string) }

    before do
      parser.parse
    end

    it "recognizes the Robyn user" do
      expect(parser.subject).to eq(@robyn)
    end

    it "maps to Robyn's check_points method" do
      expect(parser.property).to eq(:check_points)
    end

  end

  context "Alice, is the tomato cursed?" do

    let(:command_string)  { Message::CommandString.new("#{ENV['BOT_NAME']}, is the tomato cursed?") }
    let(:parser)          { Parser::Mash.new(command_string) }

    before do
      parser.parse
    end

    it "recognizes the tomato object" do
      expect(parser.object).to eq(@tomato)
    end

    it "maps to the object's is_cursed? method" do
      expect(parser.property).to eq(:is_cursed?)
    end

  end

end
