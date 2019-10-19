# frozen_string_literal: true

CommandDispatcher.register name: 'quotes', help_text: 'displays the amount of quotes related to a user or a channel' do |msg, args|
  subject = args.parsed[0]
  field = Quote.subject_type subject

  if !field
    msg.reply 'invalid subject, try a user or a channel.'
    next
  end

  begin
    _, _, count = Quote.search field: field, value: subject, id: 1
    msg.reply "#{subject} has **#{count}** quote#{count != 1 ? 's' : ''} on record."
  rescue StandardError => ex
    msg.reply ex.message
  end
end

CommandDispatcher.alias 'qs', 'quotes'
CommandDispatcher.alias 'quote_count', 'quotes'
CommandDispatcher.alias 'count_quotes', 'quotes'
