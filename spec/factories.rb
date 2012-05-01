# By using the symbol ':user', we get Factory Girl to simulate the User model.

Factory.define :user do |user|
  user.name			"Test User"
  user.email			"testuser@redpuma.com"
  user.password			"testuser"
  user.password_confirmation	"testuser"
end

Factory.sequence :email do |n|
  "testuser-#{n}@redpuma.com"
end
