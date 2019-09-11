class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.string :title, index: true
      t.string :link
      t.text :body
      t.references :user, null: false, foreign_key: true, index: true
      t.integer :upvotes
      t.integer :downvotes

      t.timestamps
    end
  end
end
