class AddCommentsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.text :content, null: false
      t.timestamps
    end
    add_reference :comments, :task, foreign_key: true
    add_reference :comments, :user, foreign_key: true
  end
end
