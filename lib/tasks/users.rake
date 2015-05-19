namespace :users do
  desc "TODO"
  task load: :environment do
    puts 'begin'
    (2289..6743).each do |u|
      user = User.where(id: u).first
      unless user
        user = User.create(id: u)
        puts u
      end
    end
    puts 'done'
  end

  task pop: :environment do
    puts 'begin'
    f = File.open("/tmp/ratings.csv", 'r+')
    f.each_line do |line|
      s = line.split(',')
      u = s[0]

      break if u.to_i > 6743
      m = s[1]
      r = s[2]
      Rating.create(user: u.to_s, movie: m.to_s, value: r)
      print '.'
    end
    puts 'done'
  end

end
