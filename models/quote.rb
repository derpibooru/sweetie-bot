# frozen_string_literal: true

# Quotes model. Responsible for creating and removing quotes.
# @author Luna aka Meow the Cat
class Quote < ActiveRecord::Base
  validates :body, uniqueness: { scope: :user, message: 'quote already exists' }
  validates :body, presence: true
  validates :user, presence: true
  validates :channel, presence: true

  # Adds a new quote.
  #
  # @param user [String] full Discord User ID (`<@123456...>`) of the user the quote belongs to.
  # @param channel [String] full Discord Channel ID (`<#123456...>`) of the channel the quote was created in.
  # @param body [String] the text of the quote.
  # @return [Quote] the newly created quote.
  def self.add(user, channel, body)
    Quote.create! user: user.gsub(/^<@!/, '<@'), channel: channel, body: body.strip
  end

  # Searches for a quote based on the search parameters.
  # @note Raises `StandardError` with error message if the ID is out of range,
  #   quote is not found, or no quotes are present at all.
  # @note Uses database order of the quote, not the `#id` field!
  #
  # @return [Quote] the matching quote.
  # @return [Number] ID of the quote, not using the `#id` parameter, but rather it's actual position in the database.
  # @return [Number] total amount of matching quotes found.
  def self.search(**args)
    quotes = Quote.where args[:field] => args[:value].gsub(/^<@!/, '<@')
    quote_count = quotes.count

    raise 'no quotes on record.' if quote_count < 1

    id = args[:id] || rand(1..quote_count)

    raise 'ID out of range.' if id.to_i <= 0 || quote_count < id

    if (q = quotes.order(created_at: :asc).offset(id - 1).first)
      [q, id, quote_count]
    else
      raise 'quote not found.'
    end
  end

  # Removes a quote belonging to a specific user by it's position.
  # @note Uses database order of the quote, not the `#id` field!
  #
  # @param user [String] full Discord User ID (`<@123456...>`) of the user the quote belongs to.
  # @param id [Number] ID of the quote to remove.
  def self.remove(user, id)
    search(field: :user, value: user.gsub(/^<@!/, '<@'), id: id)[0].destroy
  end

  # Removes a quote made in a specific channel by it's position.
  # @note Uses database order of the quote, not the `#id` field!
  #
  # @param chan [String] full Discord Channel ID (`<#123456...>`) of the channel the quote was created in.
  # @param id [Number] ID of the quote to remove.
  def self.remove_from_channel(chan, id)
    search(field: :channel, value: chan, id: id)[0].destroy
  end

  # Gets the type of the subject derived from the Discord ID.
  # @note Possible subject types: `:user`, `:channel` or `:id`
  #
  # @param subject [String] the subject to determine the type of.
  # @return [Symbol, false] the type of the subject, false if the subject is invalid.
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
