class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.references :user, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.references :parent
      t.text :text

      t.timestamps
    end
  end
end
