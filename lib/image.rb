# frozen_string_literal: true

require 'active_support/core_ext'
require 'relative_time'

# A class responsible for handling booru image-related things.
# @author Luna aka Meow the Cat
class Image
  RATING_TAGS = %w[semi-grimdark grimdark grotesque safe suggestive questionable explicit].freeze
  RATING_TAG_REGEX = /[\A,](semi\-grimdark|grimdark|grotesque|safe|suggestive|questionable|explicit)[\Z,]/.freeze

  # Sends an image as a reply to the message.
  # @param msg [Discordrb::Events::MessageEvent] message object.
  # @param id [Number] ID of the image.
  # @return [true, false] `true` if the image was found, `false` otherwise.
  def self.send_image(msg, id)
    img = Booru.image(id, msg.channel.check_nsfw?)

    if img
      embed img, message: msg
      return true
    end

    false
  end

  # Sends an image as an embed, replying to a message.
  # @param img [Number] ID of the image.
  # @param args [Hash] options for the embed.
  # @option args [Discordrb::Events::MessageEvent] :message The message object
  # @option args [String] :description Description of the image to send.
  # @return [false] `false` if the image is censored by the YAML filters.
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

    is_webm = img.mime_type == 'video/webm'

    embed_text = if img.spoilered
      "This **#{rating(img)}** image is spoilered by my current filter (may contain episode spoilers)!\n||https:#{img.representations.full}||"
    else
      ''
    end

    rendered_tags = Image.sort_tags(img.tags).join(', ')

    embed = EmbedBuilder.build do |embed|
      embed.url = "https://derpibooru.org/#{img.id}"
      embed.title = "#{img.id} (#{rating(img)})"
      embed.description = description
      embed.timestamp = time
      embed.color = rating_color(rating(img))

      unless is_webm
        embed.image "https:#{img.representations.full}"
      end
  
      embed.field do |f|
        f.name = 'Tags'
        f.value = rendered_tags.length < max_tags_len ? rendered_tags : "#{rendered_tags[0..max_tags_len]}..."
      end

      embed.field do |f|
        f.name = 'Comments'
        f.value = "**#{img.comment_count}**"
        f.inline = true
      end

      embed.field do |f|
        f.name = 'Score'
        f.value = "#{img.upvotes}⭡  **#{img.score}**  ⭣#{img.downvotes}"
        f.inline = true
      end

      embed.footer "Uploaded #{nice_time} by #{img.uploader}."
    end

    message.send_message embed_text, false, embed

    if is_webm
      if !img.spoilered
        message.send_message "https:#{img.representations.full}"
      else
        message.send_message "||https:#{img.representations.full}||"
      end
    end
  end

  # Sorts the given array of tags, prioritizing artists and ratings tags.
  # @param tags [String] the tag list as a string (as returned by the API).
  # @return [Array<String>] array of the sorted tags, WITH DISCORD FORMATTING.
  def self.sort_tags(tags)
    pieces = tags.split ', '

    artist_tags = pieces.select { |t| t.start_with? 'artist' }
                        .map { |t| "**#{t}**" }
    rating_tags = pieces.select { |t| Image::RATING_TAGS.include? t }
                        .map { |t| "**#{t}**" }
    remainder = pieces.select { |t| !t.start_with?('artist') && !Image::RATING_TAGS.include?(t) }

    rating_tags + artist_tags + remainder
  end

  # Reads the content rating tag of the image.
  # @param img [Hash] Image data.
  # @return [String] Rating tag, or "unknown" if none are present.
  def self.rating(img)
    match = img.tags.gsub(/, /, ',').match Image::RATING_TAG_REGEX
    match[1] || 'unknown'
  end

  # Determines whether a set of tags has certain tag or not.
  # @param img [Array<String>] tag data.
  # @param tag [String] tag to search for.
  # @return [Boolean] whether the tag is present or not.
  def self.tags_contain?(tags, tag)
    match = tags.gsub(/, /, ',').match /[\A,](#{tag})[\Z,]/
    (match && match[1]) ? true : false
  end

  # Determines whether an image has certain tag or not.
  # @param img [Hash] image data.
  # @param tag [String] tag to search for.
  # @return [Boolean] whether the tag is present or not.
  def self.tag?(img, tag)
    Image.tags_contain? img.tags, tag
  end

  # Returns the color based on rating, in Discord's number notation.
  # @param rating [String] rating tag.
  # @return [Number] Color code as a 24-bit number.
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

  # Checks if the image is censored by the YAML filters or not.
  # @param img [Hash] image data.
  # @return [true, false] `true` if censored, `false` otherwise.
  def self.censored?(img)
    censored_tags = Booru.hidden_tags
    tags = img.tags

    censored_tags.each do |censor|
      if censor.is_a?(String)
        return true if Image.tags_contain? tags, censor
      else
        return true unless censor.map do |tag|
          if tag.start_with? '!'
            !Image.tags_contain? tags, tag[1..]
          else
            Image.tags_contain? tags, tag
          end
        end.include?(false)
      end
    end

    false
  end
end
