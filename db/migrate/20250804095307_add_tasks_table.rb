class AddTasksTable < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.timestamp :due_date
      t.integer :status, default: 0
      t.text :description
      t.timestamp :deleted_at
      t.timestamps
    end
    add_reference :tasks, :project, foreign_key: true
  end
end
