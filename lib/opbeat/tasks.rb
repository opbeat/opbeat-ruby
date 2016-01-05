namespace :opbeat do
  desc "Notify Opbeat of a release"
  task :release => :environment do
    unless rev = ENV["REV"]
      puts "Please specify a revision in an env variable\n" +
        "eg. REV=abc123 rake opbeat:release"
      exit 1
    end

    # empty env means dev
    ENV["RAILS_ENV"] ||= 'development'

    # log to STDOUT
    Opbeat::Client.inst.config.logger = Logger.new STDOUT

    unless Opbeat.release(rev: rev, branch: ENV['BRANCH'], status: 'completed')
      exit 1 # release returned nil
    end
  end

  task :deployment => :release
end
