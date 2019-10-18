# frozen_string_literal: true

ActiveRecord::Schema.define do
  if !ActiveRecord::Base.connection.table_exists? 'quotes'
    create_table :quotes do |t|
      t.string :user
      t.string :channel
      t.text :body
      t.timestamps
    end
  end
end
