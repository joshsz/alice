class Alice::Fruitcake

  include Mongoid::Document

  attr_accessor :message

  belongs_to :user

  def self.transfer
    first || create
  end

  def transferable?
    self.message.nil?
  end

  def from(name)
    return self unless self.user
    return self.user.has_nick?(name) && self
    self.message = "Only #{user.primary_nick.titleize} can pass the sacred fruitcake!" 
    self
  end

  def to(name)
    self.message = "You can't pass fruitcakes to imaginary friends." unless recipient = Alice::User.find_or_create(name)
    if transferable?
      self.message = "#{owner} passes the fruitcake to #{recipient.primary_nick.capitalize}."
      self.user = recipient
      self.save
    end
  end
  
  def owner
    self.user.primary_nick.capitalize
  end

end
