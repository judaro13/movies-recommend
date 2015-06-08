require 'active_support/inflector'
class Movie
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :genres, type: Array, default: []
  field :directors, type: Set, default: Set.new
  field :producers, type: Set, default: Set.new
  field :writers,   type: Set, default: Set.new
  field :narrators, type: Set, default: Set.new
  field :starrings, type: Set, default: Set.new
  field :cinematographies, type: Set, default: Set.new
  field :music_composers,  type: Set, default: Set.new
  field :release_year,     type: Integer
  field :fix_me, type: Boolean, default: false

  has_many :ratings

  # removing non valid characters
  def fix_name
    fname = self.name
    fname = fname.gsub!(/[!@%:"]/,'')
    fname = fname.gsub('&', 'and')
    fname = fname.gsub("+", ".")
    fname = I18n.transliterate(fname)
    self.name = fname
    self.save
  end

  # enriching database attributes with dbpedia queries
  def enrich
    filter_q1 = "FILTER (?s = <http://dbpedia.org/resource/#{film_name}>)"
    filter_q2 = "FILTER (?s = <http://dbpedia.org/resource/#{film_name}_(film)>)" 
    filter_q3 = "FILTER (?s = <http://dbpedia.org/resource/#{film_name}_(#{self.release_year.to_s}_film)>)"

    [filter_q1, filter_q2, filter_q3].each do |f|
      q = query(f)
      sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
      result = sparql.query(q)
      if !result.empty? 
        set_results(result)
      end
      if valid_film?
        self.fix_me = false
        self.save
        print '.'
        break
      end
    end 
    if !valid_film?
      print 'f'
    end
  end

  def valid_film?
    !self.directors.empty? || !self.producers.empty? || !self.writers.empty? || !self.starrings.empty?
  end

  def set_results(result)
    result.each do |re|
      [:music, :director, :producer, :starring, :writer, :narrator, :cinema].each do |item|
        data = re[item].to_s.gsub('http://dbpedia.org/resource/', '')
        next unless data
        data = data.split("_")
        data = data.join(' ')

        if item == :cinema
          self.cinematographies << data
        elsif item == :music
          self.music_composers << data
        else
          begin
            self["#{item}s"] << data
          rescue
            binding.pry
          end
        end
      end
    end
    self.save
  end

  #Sparql query to dbpedia
  def query(filter)
    'SELECT DISTINCT ?s ?director ?editing ?producer ?starring ?writer ?music ?narrator ?cinema
              WHERE {
                ?s <http://dbpedia.org/ontology/wikiPageID> ?id.
                '+filter+'
                OPTIONAL {?s dbpedia-owl:director ?director}.
                OPTIONAL {?s dbpedia-owl:editing ?editing}.
                OPTIONAL {?s dbpedia-owl:producer ?producer}.
                OPTIONAL {?s dbpedia-owl:starring ?starring}.
                OPTIONAL {?s dbpprop:starring ?starring}.
                OPTIONAL {?s dbpedia-owl:writer ?writer}.
                OPTIONAL {?s dbpprop:music ?music}.
                OPTIONAL {?s dbpprop:narrator ?narrator}.
                OPTIONAL {?s dbpprop:cinematography ?cinema}.
              }'
  end

  def film_name
    fname = self.name.split(" ")
    fname.each{|s| fname.delete(s) if s.include?('(')}
    fname = fname.join('_') 
    fname = fname.gsub(')',"").gsub('(', "")
  end
end
