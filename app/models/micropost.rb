class Micropost < ActiveRecord::Base
  # TODO: may have a security flaw here, where a hacker can edit the
  # score of a particular micropost
  attr_accessible :description, :score

  belongs_to :user

  validates :description, :presence => true, :length => { :maximum => 140 }
  # TODO Add a maximum possible value for score
  # validates :score, 	  :presence => true
  validates :user_id,     :presence => true

  default_scope :order => 'microposts.created_at DESC'

  # Return microposts from the user being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  private

    # Return an SQL condition for users followed by the given user.
    # We include the user's own id as well
    def self.followed_by(user)
      followed_ids = %(SELECT followed_id FROM relationships
		       WHERE follower_id = :user_id)
      where("user_id IN (#{followed_ids}) OR user_id = :user_id",
		{ :user_id => user })
    end
end
