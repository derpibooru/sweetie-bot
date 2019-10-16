CommandDispatcher.register name: 'tag' do |msg, args|
  data = Booru.tag args.raw

  if msg.discord?
    text = "<https://derpibooru.org/tags/#{data.tag.slug}> - #{data.tag.images} images are tagged '#{data.tag.name}'.\n"
  else
    text = "https://derpibooru.org/tags/#{data.tag.slug} - #{data.tag.images} images are tagged '#{data.tag.name}'.\n"
  end
  text += "#{data.tag.short_description}\n" if data.tag.short_description.present?
  text += "Implies: #{data.tag.implied_tags.join(', ')}" unless data.tag.implied_tags.empty?

  msg.reply with: text, mention: false
end

CommandDispatcher.alias 't', 'tag'
