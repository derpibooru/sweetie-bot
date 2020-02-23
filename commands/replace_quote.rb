# frozen_string_literal: true

CommandDispatcher.register name: 'replace_quote', help_text: '(admin) replaces a specific quote' do |msg, args|
  subject = args.parsed[0]
  field = Quote.subject_type subject
  quote_id = args.parsed[1] ? args.parsed[1].to_i : false
  body = args.parsed[2..].join(' ')

  next if !field || field == :id
  next if !quote_id
  next if !User.admin?(msg.sender.id)

  begin
    case field
    when :user
      Quote.replace subject, quote_id, body
    when :channel
      Quote.replace_on_channel subject, quote_id, body
    end

    escaped_name = msg.escape_name(subject)

    msg.reply "Quote ##{quote_id} replaced on **#{escaped_name}**.\n**#{escaped_name}**: #{body}", mention: false
  rescue StandardError => ex
    msg.reply ex.message
  end
end

CommandDispatcher.alias 'rq', 'replace_quote'
CommandDispatcher.alias 'qr', 'replace_quote'
