# frozen_string_literal: true

CommandDispatcher.register name: 'tag' do |msg, args|
  data = Booru.tag args.raw

  text = if msg.discord?
    "<https://derpibooru.org/tags/#{data.tag.slug}> - #{data.tag.images} images are tagged '#{data.tag.name}'.\n"
  else
    "https://derpibooru.org/tags/#{data.tag.slug} - #{data.tag.images} images are tagged '#{data.tag.name}'.\n"
  end

  text += "#{data.tag.short_description}\n" if data.tag.short_description.present?
  text += "Aliases: #{data.aliases.join(', ')}" unless data.aliases.empty?
  text += "Implies: #{data.tag.implied_tags.join(', ')}" unless data.tag.implied_tags.empty?

  msg.reply with: text, mention: false
end

CommandDispatcher.alias 't', 'tag'
