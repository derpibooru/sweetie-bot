# frozen_string_literal: true

class Quote < ActiveRecord::Base
  validates :body, uniqueness: { scope: [:user, :channel], message: 'quote already exists' }

  def self.add(user, channel, body)
    Quote.create! user: user, channel: channel, body: body.strip
  end

  def self.search(**args)
    quotes = Quote.where args[:field] => args[:value]
    quote_count = quotes.count

    raise 'no quotes on record.' if quote_count < 1

    id = args[:id] || rand(1..quote_count)

    raise 'ID out of range.' if id.to_i <= 0 || quote_count < id

    if (q = quotes.order(created_at: :asc).offset(id - 1).first)
      return q, id, quote_count
    else
      raise 'quote not found.'
    end
  end

  def self.remove(user, id)
    search(field: :user, value: user, id: id)[0].destroy
  end

  def self.remove_from_channel(chan, id)
    search(field: :channel, value: chan, id: id)[0].destroy
  end

  def self.subject_type(subject)
    return false unless subject.is_a? String

    case subject[0..1]
    when '<@'
      :user
    when '<#'
      :channel
    else
      if subject.match? /^[0-9]+$/
        :id
      else
        false
      end
    end
  end
end
