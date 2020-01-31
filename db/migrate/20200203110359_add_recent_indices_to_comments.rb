class AddRecentIndicesToComments < ActiveRecord::Migration[6.0]
  def change
    change_table :comments do |t|
      t.index %i[post_id created_at],
              order: { created_at: :desc },
              where: 'parent_id IS NULL'
      t.index %i[post_id parent_id created_at],
              order: { parent_id: :asc, created_at: :asc },
              where: 'parent_id IS NOT NULL'
    end
  end
end
