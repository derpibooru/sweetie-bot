# frozen_string_literal: true

class Quote < ActiveRecord::Base
  validates :body, uniqueness: { scope: [:user, :channel], message: 'quote already exists' }

  def self.add(user, channel, body)
    Quote.create! user: user, channel: channel, body: body.strip
  end

  def self.search(**args)
    id = args[:id] || 1

    quotes = Quote.where args[:field] => args[:value]

    raise 'ID out of range' if id.to_i <= 0 || quotes.count < id

    if (q = quotes.order(created_at: :asc).offset(id - 1).first)
      q
    else
      raise 'quote not found'
    end
  end

  def self.remove(user, id)
    search(field: :user, value: user, id: id).destroy!
  end

  def self.remove_from_channel(chan, id)
    search(field: :channel, value: chan, id: id).destroy!
  end
end
