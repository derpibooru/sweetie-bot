# frozen_string_literal: true

CommandDispatcher.register name: 'tag' do |msg, args|
  tag_data = Booru.tag args.raw
  tag = tag_data.tag

  text = "<https://derpibooru.org/tags/#{tag.slug}> - **#{tag.images}** images are tagged '_#{tag.name}_'.\n"
  text += "#{tag.short_description}\n" if tag.short_description.present?
  text += "**Aliases:** #{tag_data.aliases.join(', ')}\n" unless tag_data.aliases.empty?
  text += "**Implies:** #{tag.implied_tags.join(', ')}" unless tag.implied_tags.empty?

  msg.reply with: text, mention: false
end

CommandDispatcher.alias 't', 'tag'
