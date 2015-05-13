class Movie
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :genre, type: Array, default: []
  field :directors, type: Array, default: []
  field :producers, type: Array, defualt: []
  field :writers, type: Array, default: []
  field :narrators,type: Array, default: []
  field :starrings, type: Array, default: []
  field :cinematographies, type: Array, default: []
  field :music_composers, type: Array, default: []
  field :release_date, type: Date
end
