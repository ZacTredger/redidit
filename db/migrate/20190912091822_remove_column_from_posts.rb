class RemoveColumnFromPosts < ActiveRecord::Migration[6.0]
  def change

    remove_column :posts, :upvotes, :integer

    remove_column :posts, :downvote, :integer

    remove_column :posts, :downvotes, :integer
  end
end
