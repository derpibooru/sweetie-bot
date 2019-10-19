# frozen_string_literal: true

CommandDispatcher.register name: 'roll', help_text: 'generates a random number' do |msg, args|
  ceil = args.raw.to_i if args.present?
  ceil ||= 24

  msg.reply with: "#{msg.sender.mention} has rolled **#{rand(ceil)}** out of **#{ceil}**.", mention: false
end

CommandDispatcher.alias 'r', 'roll'
