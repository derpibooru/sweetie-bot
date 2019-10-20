class ChangeQuoteIndex < ActiveRecord::Migration[6.0]
  def up
    Quote.all.each do |q|
      Quote.where(user: q.user, body: q.body).where('id != ?', q.id).delete_all
    end

    remove_index :quotes, column: [:body, :user, :channel]
    add_index :quotes, [:body, :user], unique: true
  end

  def down
    remove_index :quotes, [:body, :user]
    add_index :quotes, column: [:body, :user, :channel], unique: true
  end
end
