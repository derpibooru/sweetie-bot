class CreateBaseStructure < ActiveRecord::Migration[6.0]
  def up
    create_table :quotes do |t|
      t.string :user
      t.string :channel
      t.text :body
      t.timestamps
    end

    create_table :users do |t|
      t.string :name
      t.boolean :admin, default: false
      t.timestamps
    end

    add_index :quotes, [:body, :user, :channel], unique: true
    add_index :quotes, :user
    add_index :quotes, :channel
    add_index :users, :name
    add_index :users, :admin
  end

  def down
    remove_index :quotes, column: [:body, :user]
    remove_index :quotes, column: :user
    remove_index :quotes, column: :channel
    remove_index :users, column: :name
    remove_index :users, column: :admin

    drop_table :users
    drop_table :quotes
  end
end
