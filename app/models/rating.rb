require 'active_support/inflector'
class Rating
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :movie
  belongs_to :user

  field :value

end
