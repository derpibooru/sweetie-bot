# frozen_string_literal: true

ActiveRecord::Schema.define do
  if !ActiveRecord::Base.connection.table_exists? 'quotes'
    create_table :quotes do |t|
      t.integer :quote_num
      t.string :user
      t.text :body
      t.timestamps
    end
  end
end
