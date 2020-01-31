class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.references :user, foreign_key: true, index: false
      t.references :post, null: false, foreign_key: true, index: false
      t.references :parent, index: false
      t.text :text

      t.timestamps
    end
  end
end
