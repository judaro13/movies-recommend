namespace :movies do
  desc "TODO"
  task load: :environment do
    puts 'begin'
    f = File.open("/tmp/movies.csv", 'r+')
    f.each_line do |line|
      binding.pry
    end
    f.close
    puts 'done'
  end

end
