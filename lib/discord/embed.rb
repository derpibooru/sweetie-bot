# frozen_string_literal: true

# Handles building of Discord embeds.
# @author Luna aka Meow the Cat
# @attr [Discordrb::Webhooks::Embed] raw The raw embed.
# @attr [Number] color Embed color.
# @attr [String] description Description of the embed.
# @attr [Time, DateTime, Date] timestamp Timestamp to be displayed at the bottom of the embed.
# @attr [String] title Title of the embed to replace the URL.
# @attr [String] url URL of the embed to open when the title is clicked.
class EmbedBuilder
  attr_accessor :raw, :color, :description, :timestamp, :title, :url

  # Builds a new embed.
  # @note `video` parameter is untested and likely doesn't work.
  # @param video [Discordrb::EmbedVideo] The video to embed.
  # @yield [new_embed] The builder for easy building.
  # @yieldparam [EmbedBuilder] new_embed The embed builder object.
  # @return [Discordrb::Webhooks::Embed] The generated embed.
  def self.build(video = nil)
    new_embed = EmbedBuilder.new video
    yield new_embed
    new_embed.raw.color ||= new_embed.color
    new_embed.raw.description ||= new_embed.description
    new_embed.raw.timestamp ||= new_embed.timestamp
    new_embed.raw.title ||= new_embed.title
    new_embed.raw.url ||= new_embed.url
    new_embed.raw
  end

  # @param video [Discordrb::EmbedVideo] The video to embed. Likely broken. Dramatically.
  def initialize(video = nil)
    @raw = Discordrb::Webhooks::Embed.new video: video
  end

  # Adds a field to the embed object.
  # @yield [field] The builder for easy building.
  # @yieldparam [Discordrb::Webhooks::EmbedField] field The raw field object.
  def field
    field = Discordrb::Webhooks::EmbedField.new
    yield field
    @raw << field
  end

  # Adds an author field to the embed object.
  # @param name [String] The name of the author to generate.
  # @param icon [String] The icon to use as author's avatar.
  # @param url [String] The URL to redirect to if the author is clicked.
  def author(name, icon, url = nil)
    @raw.author = Discordrb::Webhooks::EmbedAuthor.new name: name, url: url, icon_url: icon
  end

  # Adds an image field to the embed object.
  # @param url [String] The URL of the image to embed.
  def image(url)
    @raw.image = Discordrb::Webhooks::EmbedImage.new url: url
  end

  # Adds an image thumbnail to the embed object.
  # @param url [String] The URL of the thumbnail.
  def thumbnail(url)
    @raw.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: url
  end

  # Adds the footer text to the embed object.
  # @param text [String] The text to display in the footer.
  # @param icon [String] The URL of the icon to put in the footer. Replaces text (methinks).
  def footer(text, icon = nil)
    @raw.footer = Discordrb::Webhooks::EmbedFooter.new text: text, icon_url: icon
  end
end
