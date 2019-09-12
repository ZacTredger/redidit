class CreatePostVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :post_votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.boolean :up

      t.timestamps
    end
  end
end
