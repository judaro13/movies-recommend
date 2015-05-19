require 'active_support/inflector'
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :ratings

  field :total_ratings

  def set_total_ratings
    self.set(total_ratings: self.ratings.count)
  end
end
