require 'relative_time'
require 'active_support/core_ext'

CommandDispatcher.register name: 'pony' do |msg, args|
  data = Booru.random_image args.raw, msg.channel.nsfw?

  if data
    time = Time.parse(data.created_at)
    nice_time = RelativeTime.in_words(time)

    if msg.discord?
      msg.raw.send_embed "" do |embed|
        embed.url = "https://derpibooru.org/#{data.id}"
        embed.title = "#{data.id.to_s} (#{Derpibooru.rating(data)})"
        if args.raw.present?
          embed.description = data.description.length < 256 ? data.description : "#{data.description[0..252]}..."
        else
          embed.description = "PONY PONY PONY"
        end
        embed.image = Discordrb::Webhooks::EmbedImage.new(url: "https:#{data.representations.large}")
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https:#{data.representations.thumb_small}")
        embed.timestamp = time

        tags = Discordrb::Webhooks::EmbedField.new
        tags.name = 'Tags'
        tags.value = data.tags.length < 1024 ? data.tags : "#{data.description[0..1020]}..."

        stats = Discordrb::Webhooks::EmbedField.new
        stats.name = 'Statistics'
        stats.value = <<~STATS
          Uploader: #{data.uploader}
          Resolution: #{data.width}x#{data.height} (#{data.original_format})
          #{data.comment_count} comments posted, score is #{data.score} (#{data.upvotes} up, #{data.downvotes} down)
        STATS

        embed.fields = [
          tags, stats
        ]

        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Uploaded #{nice_time}.")
      end
    end
  end
end

CommandDispatcher.alias 'p', 'pony'
