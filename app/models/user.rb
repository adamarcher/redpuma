class User < ActiveRecord::Base

  require 'digest'

  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation, :total_score

  has_many :microposts, 	   :dependent => :destroy
  has_many :relationships, 	   :foreign_key => "follower_id",
			   	   :dependent => :destroy
  has_many :following, 		   :through => :relationships,
				   :source => :followed
  has_many :reverse_relationships, :foreign_key => "followed_id",
			           :class_name => "Relationship",
				   :dependent => :destroy
  has_many :followers, 		   :through => :reverse_relationships,
				   :source => :follower

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  approved_users = /lillianbarcher@gmail.com|jesselevey@gmail.com|leah.hefner@gmail.com|tristan.heinrich@gmail.com|willis.tyler@gmail.com|ajbellis@gmail.com|benrgurin@gmail.com|travis@peoplebrowsr.com|marayakarena@gmail.com|joanna.gurin@gmail.com|krsgoss@gmail.com|mark.williamson@gmail.com|hello@ryanfosterdesign.com|docfranky@gmail.com|jamiemcd09@gmail.com|russell.siegelman@gmail.com|bbchamberlain@gmail.com|ashleybaharestani@gmail.com|amit.kapoor.wg08@gmail.com|rachel.berger11@gmail.com|davebergler@gmail.com|aliciablevey@gmail.com|townsend.joseph@gmail.com|devuser-?\d*@redpuma.com|testuser-?\d*@redpuma.com|me@adamarcher.com|admin@redpuma.com|setharcher@gmail.com|testuser-?\d*@example.com|TESTUSER@EXAMPLE.COM/

  validates :name,  :presence	=> true,
		    :length   	=> { :maximum => 50 }

  validates :email, :presence 	=> true,
		    # TODO: revert back to email_regex once we open this up to all users
		    :format   	=> { :with => approved_users},
		    :uniqueness => { :case_sensitive => false } 
  
  # Automatically create the virtual attribute 'password_confirmation'.
  validates :password, :presence	=> true,
		       :confirmation	=> true,
		       :length		=> { :within => 6..40 } 

  before_save :encrypt_password

  # Return true if the user's password matches the submitted password.
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  # Return a) an authenitcated user on password match, b) nil if the
  # user's email can't be found or, c) nil implicetely on password
  # mismatch
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user: nil
  end

  def feed
    Micropost.from_users_followed_by(self)
  end

  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end

  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end

  private

    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end

end

# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

