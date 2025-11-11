# frozen_string_literal: true

CommandDispatcher.register name: 'appeal', help_text: 'allows access to the #ban-appeals channel' do |msg, args|
  appeal = args.parsed[0]
  appeals_role = SweetieBot.config.discord.appeals_role
  appeals_channel = SweetieBot.config.discord.appeals_channel

  roles = msg.server.roles.select { |r| r.id.to_s == appeals_role }

  if roles.empty?
    msg.reply 'appeals role is not configured properly.', mention: false
    next
  end

  role = roles.first

  begin
    case appeal
    when nil
      next if msg.sender.role?(role)

      msg.sender.add_role(role)
      msg.reply "please proceed to <\##{appeals_channel}> to speak with site staff privately. If appealing a ban, have your ban ID ready.\n\nWhen you are done, use `.appeal exit`."
    when 'exit'
      next if !msg.sender.role?(role)

      msg.sender.remove_role(role)
      msg.reply "#{msg.sender.mention} exited", mention: false
    end
  rescue StandardError => ex
    msg.reply ex.message
  end
end

CommandDispatcher.alias 'appeals', 'appeal'
