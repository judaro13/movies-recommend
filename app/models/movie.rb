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
# m = Movie.where(fix_me: true).first

  def fix_name
    fname = self.name
    fname = fname.gsub('&', 'and')
    fname = fname.gsub(".", "")
    fname = fname.gsub("!", "")
    fname = fname.gsub("'", "")
    fname = fname.gsub(":", "")
    fname = fname.gsub("/", "")
    fname = fname.gsub("?", "")
    fname = fname.gsub("+", ".")
    fname = I18n.transliterate(fname)
    self.name = fname
    self.save
  end

  def fix

    [query1, query2, query3, query4].each do |q|

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
    music = Set.new
    director = Set.new
    editing = Set.new
    producer = Set.new
    starring = Set.new
    writer = Set.new
    narrator = Set.new
    cinema = Set.new

    result.each do |re|
      if re.bound?(:music)
        m = re.music.to_s.gsub('http://dbpedia.org/resource/', '')
        m = m.split("_")
        m.each{|s| m.delete(s) if s.include?('(')}
        m = m.join(' ')
        music << m
      end

      if re.bound?(:director)
        m = re.director.to_s.gsub('http://dbpedia.org/resource/', '')
        m = m.split("_")
        m.each{|s| m.delete(s) if s.include?('(')}
        m = m.join(' ')
        director << m
      end

      if re.bound?(:editing)
        m = re.editing.to_s.gsub('http://dbpedia.org/resource/', '')
        m = m.split("_")
        m.each{|s| m.delete(s) if s.include?('(')}
        m = m.join(' ')
        editing << m
      end

      if re.bound?(:producer)
        m = re.producer.to_s.gsub('http://dbpedia.org/resource/', '')
        m = m.split("_")
        m.each{|s| m.delete(s) if s.include?('(')}
        m = m.join(' ')
        producer << m
      end

      if re.bound?(:starring)
        m = re.starring.to_s.gsub('http://dbpedia.org/resource/', '')
        m = m.split("_")
        m.each{|s| m.delete(s) if s.include?('(')}
        m = m.join(' ')
        starring << m
      end

      if re.bound?(:writer)
        m = re.writer.to_s.gsub('http://dbpedia.org/resource/', '')
        m = m.split("_")
        m.each{|s| m.delete(s) if s.include?('(')}
        m = m.join(' ')
        writer << m
      end

      if re.bound?(:narrator)
        m = re.narrator.to_s.gsub('http://dbpedia.org/resource/', '')
        m = m.split("_")
        m.each{|s| m.delete(s) if s.include?('(')}
        m = m.join(' ')
        narrator << m
      end

      if re.bound?(:cinema)
        m = re.cinema.to_s.gsub('http://dbpedia.org/resource/', '')
        m = m.split("_")
        m.each{|s| m.delete(s) if s.include?('(')}
        m = m.join(' ')
        cinema << m
      end
    end
    self.directors = director
    self.producers = producer
    self.writers = writer
    self.narrators = narrator
    self.starrings = starring
    self.cinematographies = cinema
    self.music_composers = music
    self.save
  end

  def query1
    'SELECT DISTINCT ?s ?director ?editing ?producer ?starring ?writer ?music ?narrator ?cinema
              WHERE {
                ?s <http://dbpedia.org/ontology/wikiPageID> ?id.
                FILTER (?s = <http://dbpedia.org/resource/'+film_name+'>) 
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

  def query2
    'SELECT DISTINCT ?s ?director ?editing ?producer ?starring ?writer ?music ?narrator ?cinema
              WHERE {
                ?s <http://dbpedia.org/ontology/wikiPageID> ?id.
                FILTER (?s = <http://dbpedia.org/resource/'+film_name+'_(film)>) 
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

  def query3
    'SELECT DISTINCT ?s ?director ?editing ?producer ?starring ?writer ?music ?narrator ?cinema
              WHERE {
                ?s <http://dbpedia.org/ontology/wikiPageID> ?id.
                FILTER (?s = <http://dbpedia.org/resource/'+film_name+'_('+self.release_year.to_s+'_film)>) 
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

  def query4
    'SELECT DISTINCT ?s ?director ?editing ?producer ?starring ?writer ?music ?narrator ?cinema
              WHERE {
                ?s a dbpedia-owl:Film.
                ?s rdfs:label ?label .  
                ?label bif:contains "'+film_name+'" . 
                ?s dcterms:subject ?sub.
                ?s dbpprop:released ?date.
                FILTER regex(str(?date), "'+self.release_year.to_s+'").
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
