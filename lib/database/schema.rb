# frozen_string_literal: true

ActiveRecord::Schema.define do
  if !ActiveRecord::Base.connection.table_exists? 'quotes'
    create_table :quotes do |t|
      t.string :user
      t.string :channel
      t.text :body
      t.timestamps
    end

    create_table :users do |t|
      t.string :name
      t.boolean :admin
      t.timestamps
    end

    add_index :quotes, [:body, :user, :channel], unique: true
    add_index :quotes, :user
    add_index :quotes, :channel
    add_index :users, :name
    add_index :users, :admin
  end
end
