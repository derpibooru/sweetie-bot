# frozen_string_literal: true

require 'active_support/core_ext'
require 'relative_time'

class Image
  def self.embed(img, **args)
    max_desc_len = SweetieBot.instance.config['messages']['max_desc_length']
    max_tags_len = SweetieBot.instance.config['messages']['max_tag_length']

    message = args[:message] || args[:msg]
    time = Time.parse(img.created_at)
    nice_time = RelativeTime.in_words(time)
    description = args[:description] || (img.description.length < max_desc_len ? img.description : "#{img.description[0..max_desc_len]}...")

    if censored? img, message.adapter_name.to_s
      if message.discord?
        message.channel.send "Cannot display this image, it probably violates Discord's TOS, sorry!"
      else
        message.channel.send 'Cannot display this image due to my tag blacklist settings, sorry!'
      end

      return false
    end

    if message.discord?
      message.raw.send_embed '' do |embed|
        embed.url = "https://derpibooru.org/#{img.id}"
        embed.title = "#{img.id} (#{rating(img)})"
        embed.description = description
        embed.image = Discordrb::Webhooks::EmbedImage.new(url: "https:#{img.representations.full}")
        embed.timestamp = time

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
    else
      message.channel.send "https://derpibooru.org/#{img.id} (#{rating(img)}) " \
        "#{img.width}x#{img.height} (#{img.original_format}) " \
        "uploaded by #{img.uploader} #{nice_time}.\n" \
        "Tags: #{img.tags.length < max_tags_len ? img.tags : (img.tags[0..max_tags_len] + '...')}"
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

  def self.censored?(img, adapter = 'discord')
    censored_tags = Booru.hidden_tags[adapter]
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
