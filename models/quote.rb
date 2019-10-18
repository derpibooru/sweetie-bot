# frozen_string_literal: true

class Quote < ActiveRecord::Base
  validates :body, uniqueness: { scope: [:user, :channel], message: 'quote already exists' }

  class NotFound < StandardError
  end

  class InvalidID < StandardError
  end

  def self.add(user, channel, body)
    q = Quote.new
    q.user = user
    q.channel = channel
    q.body = body.strip
    q.save!

    q
  end

  def self.remove(user, id)
    user_quotes = Quote.where user: user

    raise InvalidID, 'ID out of range' if id.to_i <= 0 || user_quotes.count < id

    if (q = user_quotes.order(created_at: :asc).offset(id - 1).limit(1))
      q.destroy!
    else
      raise NotFound, 'quote not found'
    end
  end
end
