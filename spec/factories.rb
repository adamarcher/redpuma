# By using the symbol ':user', we get Factory Girl to simulate the User model.

Factory.define :user do |user|
  user.name			"Lillian Archer"
  user.email			"lillianbarcher@gmail.com"
  user.password			"blahblah"
  user.password_confirmation	"blahblah"
end
 
