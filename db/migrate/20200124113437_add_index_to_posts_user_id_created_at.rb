class AddIndexToPostsUserIdCreatedAt < ActiveRecord::Migration[6.0]
  def change
    change_table :posts do |t|
      t.index :created_at, name: 'by_recent'
      t.index %i[user_id created_at], name: 'by_user_recent'
    end
  end
end
