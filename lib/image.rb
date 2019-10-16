require 'active_support/core_ext'
require 'relative_time'

class Image
  def self.embed(**args)
    message = args[:message] || args[:msg]
    data = args[:data] || args[:image]
    time = Time.parse(data.created_at)
    nice_time = RelativeTime.in_words(time)
    description = args[:description] || (data.description.length < 256 ? data.description : "#{data.description[0..252]}...")

    if message.discord?
      message.raw.send_embed "" do |embed|
        embed.url = "https://derpibooru.org/#{data.id}"
        embed.title = "#{data.id.to_s} (#{Derpibooru.rating(data)})"
        embed.description = description
        embed.image = Discordrb::Webhooks::EmbedImage.new(url: "https:#{data.representations.large}")
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https:#{data.representations.thumb_small}")
        embed.timestamp = time

        tags = Discordrb::Webhooks::EmbedField.new
        tags.name = 'Tags'
        tags.value = data.tags.length < 1024 ? data.tags : "#{data.tags[0..1020]}..."

        stats = Discordrb::Webhooks::EmbedField.new
        stats.name = 'Statistics'
        stats.value = <<~STATS
          #{data.comment_count} comments posted, score is #{data.score} (#{data.upvotes} up, #{data.downvotes} down)
        STATS

        embed.fields = [
          tags, stats
        ]

        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Uploaded #{nice_time} by #{data.uploader}.")
      end
    else
      message.channel.send "https://derpibooru.org/#{data.id} (#{Derpibooru.rating(data)}) " +
        "#{data.width}x#{data.height} (#{data.original_format}) " +
        "uploaded by #{data.uploader} #{nice_time}.\n" +
        "Tags: #{data.tags.length < 1024 ? data.tags : (data.tags[0..1020] + '...')}"
    end
  end
end
