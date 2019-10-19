# frozen_string_literal: true

CommandDispatcher.register name: 'add_quote', help_text: 'adds a quote from a user or a channel' do |msg, args|
  subject = args.parsed[0]
  field = Quote.subject_type subject
  text = args.parsed[1..].join(' ')

  unless field && field != :id
    msg.reply 'invalid subject, try a user or a channel.'
    next
  end

  unless text.present?
    msg.reply 'please provide some text.'
    next
  end

  user, channel = nil

  case field
  when :user
    user = subject
    channel = msg.channel.mention
  when :channel
    user = subject
    channel = subject
  end

  begin
    Quote.add user, channel, text
    msg.reply "quote added (#{user}: #{text})."
  rescue ActiveRecord::RecordInvalid
    msg.reply 'this quote already exists!'
  end
end

CommandDispatcher.alias 'aq', 'add_quote'
