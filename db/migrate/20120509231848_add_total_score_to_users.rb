class AddTotalScoreToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :total_score, :integer, :default => 0
  end

  def self.down
    remove_column :users, :total_score
  end
end
