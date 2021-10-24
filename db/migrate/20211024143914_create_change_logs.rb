class CreateChangeLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :change_logs do |t|
      t.text :details
      t.references :contact, null: false, foreign_key: true

      t.timestamps
    end
  end
end
