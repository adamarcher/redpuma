# Commenting out this line to fix this issue:
# http://stackoverflow.com/questions/5013826/heroku-rake-dbmigrate-no-such-file-to-load-faker
# require 'faker'

namespace :db do
  desc "Fill database with sample data"

  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    make_users
    make_microposts
    make_relationships
  end
end

  def make_users
    admin = User.create!(:name			=> "Dev User",
		 	 :email			=> "devuser@redpuma.com",
		 	 :password		=> "devuser",
		 	 :password_confirmation => "devuser")
    admin.toggle!(:admin)
    99.times do |n|
      name = Faker::Name.name
      email = "devuser-#{n+1}@redpuma.com"
      password = "devuser"
      User.create!(:name => name,
		   :email => email,
		   :password => password,
		   :password_confirmation => password)
    end  # 99.times do |n|
  end  # def make_users

  def make_microposts
    User.all(:limit => 6).each do |user|
      50.times do
        user.microposts.create!(:description => Faker::Lorem.sentence(5), :score => 5)
      end
    end
  end  # def make_microposts

  def make_relationships
    users = User.all
    user = users.first
    following = users[1..50]
    followers = users[3..40]
    following.each { |followed| user.follow!(followed) }
    followers.each { |follower| follower.follow!(user) }
  end
