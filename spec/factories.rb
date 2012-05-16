# By using the symbol ':user', we get Factory Girl to simulate the User model.

Factory.define :user do |user|
  user.name			"Test User"
  user.email			"testuser@redpuma.com"
  user.password			"testuser"
  user.password_confirmation	"testuser"
  user.total_score		43
end

Factory.sequence :email do |n|
  "testuser-#{n}@redpuma.com"
end

Factory.define :micropost do |micropost|
  micropost.description "Micropost description here"
  micropost.score 7
  micropost.association :user
end
