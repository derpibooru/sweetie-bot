# frozen_string_literal: true

class Quote < ActiveRecord::Base
  class NotFound < StandardError
  end

  class AlreadyExists < StandardError
  end

  class InvalidID < StandardError
  end

  def self.add(user, channel, body)
    q = nil

    Quote.with_lock do
      if Quote.where(user: user, channel: channel, body: body).exists?
        raise AlreadyExists.new 'quote already exists'
      end

      q = Quote.new
      q.user = user
      q.channel = channel
      q.body = body
      q.save!
    end

    q
  end

  def self.remove(user, id)
    Quote.with_lock do
      user_quotes = Quote.where user: user

      if id.to_i <= 0 || user_quotes.count < id
        raise InvalidID.new 'ID out of range'
      end

      q = user_quotes.order(created_at: :asc).offset(id - 1).limit(1)

      if q
        q.destroy!
      else
        raise NotFound.new 'quote not found'
      end
    end
  end
end
