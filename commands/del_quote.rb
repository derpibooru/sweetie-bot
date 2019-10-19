# frozen_string_literal: true

CommandDispatcher.register name: 'del_quote' do |msg, args|
  subject = args.parsed[0]
  field = Quote.subject_type subject
  quote_id = args.parsed[1] ? args.parsed[1].to_i : false

  next if !field
  next if !quote_id
  next if !User.admin?(msg.sender.id)

  begin
    case field
    when :user
      Quote.remove subject, quote_id
    when :channel
      Quote.remove_from_channel subject, quote_id
    end

    msg.reply "quote ##{quote_id} removed from #{subject}."
  rescue StandardError => ex
    msg.reply ex.message
  end
end

CommandDispatcher.alias 'dq', 'del_quote'
CommandDispatcher.alias 'delete_quote', 'del_quote'
CommandDispatcher.alias 'remove_quote', 'del_quote'
