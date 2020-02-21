class CreateVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :votes do |t|
      t.boolean :up
      t.references :user, foreign_key: true, index: false
      t.references :votable, null: false, polymorphic: true, index: false

      t.timestamps

      t.index %i[votable_type votable_id up],
              name: 'index_votes_on_votable_type_and_votable_id_and_up_vs_down'
    end
  end
end
