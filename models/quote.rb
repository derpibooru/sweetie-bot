# frozen_string_literal: true

class Quote < ActiveRecord::Base
  def self.add(user, body)
    last_quote = Quote.where(user: user).order_by(quote_num: :asc).last

    q = Quote.new
    q.user = user
    q.body = body
    q.quote_num = last_quote ? last_quote.quote_num + 1 : 1
    q.save!

    q
  end

  def self.remove(user, id)
    q = Quote.lock.where(user: user).where(quote_num: id)

    if q
      q.destroy!
      return true
    end

    false
  end
end
