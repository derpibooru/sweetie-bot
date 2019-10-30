# frozen_string_literal: true

CommandDispatcher.register name: 'appeal', help_text: 'allows access to the #ban-appeals channel' do |msg, args|
  appeal = args.parsed[0]
  appeals_role = SweetieBot.config.discord.appeals_role

  begin
    case appeal
    when nil
      msg.sender.add_role(appeals_role)
    when 'exit'
      msg.sender.remove_role(appeals_role)
    end
  rescue StandardError => ex
    msg.reply ex.message
  end
end
