class AddKarmaCountsToPostsAndComments < ActiveRecord::Migration[6.0]
  def self.up
    add_column :posts, :karma, :integer, null: false, default: 0
    add_column :comments, :karma, :integer, null: false, default: 0
  end

  def self.down
    remove_column :posts, :karma
    remove_column :comments, :karma
  end
end
