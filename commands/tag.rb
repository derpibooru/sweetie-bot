# frozen_string_literal: true

CommandDispatcher.register name: 'tag', help_text: 'displays information about a tag' do |msg, args|
  tag = Booru.tag args.raw

  unless args.raw.present? && tag
    msg.reply with: 'invalid tag!'
    next
  end

  text = "<#{SweetieBot.config.booru.url_base}/tags/#{tag.slug}> - **#{tag.images}** images are tagged '_#{tag.name}_'.\n"
  text += "#{tag.short_description}\n" if tag.short_description.present?
  text += "**Aliases:** #{tag.aliases.join(', ')}\n" unless tag.aliases.empty?
  text += "**Implies:** #{tag.implied_tags.join(', ')}" unless tag.implied_tags.empty?

  msg.reply with: text, mention: false
end

CommandDispatcher.alias 't', 'tag'
