namespace :movies do
  desc "TODO"
  task load: :environment do
    puts 'begin'
    f = File.open("/tmp/movies.csv", 'r+')
    f.each_line do |line|
      s = line.split(',')
      m = Movie.new
      m.id = s[0]
      m.name = s[1].strip.gsub("\"", "")
      m.genres = s[2].strip.split('|')
      m.release_year = s[1].scan(/\d/).join
      m.save
      puts m.inspect
    end
    f.close
    puts 'done'
  end

  task populate: :environment do
    puts 'begin'

    max = (Movie.where(fix_me: true).count.to_f/100).ceil
    (0..max).each do |n|
      Movie.where(fix_me: true).limit(100).offset(100*n).each  do |movie|
        begin
          movie.fix_name
          movie.fix
        rescue Exception => e 
          puts e
        end
      end
    end
    puts 'done'
  end

end
