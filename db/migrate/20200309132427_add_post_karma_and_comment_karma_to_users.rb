class AddPostKarmaAndCommentKarmaToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :post_karma, :integer, null: false, default: 0
    add_column :users, :comment_karma, :integer, null: false, default: 0
  end
end
