# frozen_string_literal: true

require 'active_support/core_ext'
require 'relative_time'

class Image
  def self.send_image(msg, id)
    img = Booru.image(id, msg.channel.check_nsfw?)

    if img
      embed img, message: msg
      return true
    end

    false
  end

  def self.embed(img, **args)
    max_desc_len = SweetieBot.config.messages.max_desc_length
    max_tags_len = SweetieBot.config.messages.max_tag_length

    message = args[:message] || args[:msg]
    time = Time.parse(img.created_at)
    nice_time = RelativeTime.in_words(time)
    description = args[:description] || (img.description.length < max_desc_len ? img.description : "#{img.description[0..max_desc_len]}...")
    description = description.gsub(/(\r\n|\\r\\n|\\n)/, "\n")
    description = description.gsub(/\n\n\n/, "\n\n") while description.include?("\n\n\n")

    if censored? img
      message.channel.send "Cannot display this image, it probably violates Discord's TOS, sorry!"
      return false
    end

    embed_text = if img.spoilered
      "This **#{rating(img)}** image is spoilered by my current filter (may contain episode spoilers)!\n||http:#{img.representations.large}||"
    else
      ''
    end

    message.send_embed embed_text do |embed|
      embed.url = "https://derpibooru.org/#{img.id}"
      embed.title = "#{img.id} (#{rating(img)})"
      embed.description = description
      embed.image = Discordrb::Webhooks::EmbedImage.new(url: "https:#{img.representations.full}")
      embed.timestamp = time
      embed.color = rating_color(rating(img))

      tags = Discordrb::Webhooks::EmbedField.new
      tags.name = 'Tags'
      tags.value = img.tags.length < max_tags_len ? img.tags : "#{img.tags[0..max_tags_len]}..."

      stats = Discordrb::Webhooks::EmbedField.new
      stats.name = 'Statistics'
      stats.value = <<~STATS
        #{img.comment_count} comments posted, score is #{img.score} (#{img.upvotes} up, #{img.downvotes} down)
      STATS

      embed.fields = [
        tags, stats
      ]

      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Uploaded #{nice_time} by #{img.uploader}.")
    end
  end

  def self.rating(img)
    match = img.tags.match /\b(grimdark|semi\-grimdark|grotesque|safe|suggestive|questionable|explicit)\b/
    match[1] || 'unknown'
  end

  def self.tag?(img, tag)
    match = img.tags.match /\b(#{tag})\b/
    match && match[1]
  end

  def self.rating_color(rating)
    case rating
    when 'safe'
      '4BBA52'.to_i(16)
    when 'suggestive'
      '4B8EBA'.to_i(16)
    when 'questionable'
      'B03079'.to_i(16)
    when 'explicit'
      'C91E1E'.to_i(16)
    when 'grimdark'
      '695B4F'.to_i(16)
    when 'grotesque'
      'B3641F'.to_i(16)
    else
      'D7D7D7'.to_i(16)
    end
  end

  def self.censored?(img)
    censored_tags = Booru.hidden_tags
    tags = img.tags

    censored_tags.each do |censor|
      if censor.is_a?(String)
        return true if tags.include?(censor)
      else
        return true unless censor.map do |tag|
          if tag.start_with? '!'
            !tags.include?(tag[1..])
          else
            tags.include?(tag)
          end
        end.include?(false)
      end
    end

    false
  end
end
