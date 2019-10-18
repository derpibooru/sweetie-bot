# frozen_string_literal: true

class Quote < ActiveRecord::Base
  def self.add(user, channel, body)
    q = Quote.new
    q.user = user
    q.channel = channel
    q.body = body
    q.save!

    q
  end

  def self.remove(user, id)
    q = Quote.where(user: user).offset(id).limit(1)

    if q
      q.destroy!
      return true
    end

    false
  end
end
