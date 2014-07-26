class Command

  include Mongoid::Document

  field :name
  field :verbs, type: Array, default: []
  field :stop_words, type: Array, default: []
  field :handler_class
  field :handler_method
  field :response_kind, default: :message
  field :canned_response
  field :cooldown_minutes, type: Integer, default: 0
  field :one_in_x_odds, type: Integer, default: 1
  field :last_said_at, type: DateTime

  index({ verbs: 1 }, { unique: true })
  index({ stop_words: 1 }, { unique: true })

  validates_uniqueness_of :name
  validates_presence_of :name, :handler_class

  attr_accessor :message, :terms

  def self.default
    Command.new(handler_class: 'Handlers::Unknown')
  end

  def self.verbs_from(message)
    Alice::Parser::NgramFactory.omnigrams_from(message)
  end

  def self.verb_from(message)
    if verb = message.split(' ').select{|w| w[0] == "!"}.first
      verb[1..-1]
    end
  end

  def self.best_match(matches, verbs)
    matches.sort do |a,b|
      (a.verbs & verbs).count <=> (b.verbs & verbs).count
    end.last
  end

  def self.from(message)
    trigger = message.trigger.downcase.gsub(/[^a-zA-Z0-9\!\/\\\s]/, ' ')
    match = nil
    if verb = verb_from(trigger)
      match = any_in(verbs: verb).first
    elsif verbs = verbs_from(trigger)
      matches = with_verbs(verbs).without_stopwords(verbs)
      match = best_match(matches, verbs)
    end
    match ||= default
    match.message = message
    match
  end

  def self.process(message)
    from(message).invoke!
  end

  def self.with_verbs(verbs)
    Command.in(verbs: verbs)
  end

  def self.without_stopwords(verbs)
    Command.not_in(stop_words: verbs)
  end

  def needs_cooldown?
    return false unless self.last_said_at
    return false unless self.cooldown_minutes.to_i > 0
    Time.now < self.last_said_at + self.cooldown_minutes.minutes
  end

  def meets_odds?
    Alice::Util::Randomizer.one_chance_in(self.one_in_x_odds)
  end

  def invoke!
    return unless self.handler_class
    return if needs_cooldown?
    return unless meets_odds?
    eval(self.handler_class).process(message, self.handler_method || :process)
  end

  def terms
    @terms || TermList.new(self.verbs)
  end

  def terms=(words)
    @terms = TermList.new(words)
  end

  class TermList
    attr_accessor :words
    def initialize(terms=[])
      self.words = convert(terms)
    end

    def <<(terms)
      self.words << convert(terms)
      self.words = self.words.flatten.uniq
    end

    def convert(terms)
      [
        terms.map(&:downcase),
        terms.map{|term| Lingua.stemmer(term.downcase)}
      ].flatten.uniq
    end

    def to_a
      self.words
    end

  end

end