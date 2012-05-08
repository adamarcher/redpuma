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
end
