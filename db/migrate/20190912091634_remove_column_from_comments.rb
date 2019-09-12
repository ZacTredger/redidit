class RemoveColumnFromComments < ActiveRecord::Migration[6.0]
  def change

    remove_column :comments, :upvotes, :integer

    remove_column :comments, :downvote, :integer

    remove_column :comments, :downvotes, :integer
  end
end
