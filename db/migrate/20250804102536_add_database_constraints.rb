class AddDatabaseConstraints < ActiveRecord::Migration[7.1]
  def change
    # Add unique constraints to match model validations
    add_index :tasks, [:title, :project_id], unique: true
    add_index :projects, [:title, :user_id], unique: true
    
    # Add null constraints for required fields
    change_column_null :projects, :title, false
    change_column_null :projects, :user_id, false
    change_column_null :users, :name, false
    change_column_null :users, :email, false
    change_column_null :tasks, :project_id, false
    change_column_null :comments, :task_id, false
    change_column_null :comments, :user_id, false
  end
end
