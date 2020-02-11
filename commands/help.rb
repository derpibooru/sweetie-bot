# frozen_string_literal: true

require 'benchmark'

CommandDispatcher.register name: 'help', help_text: 'displays this help message' do |msg, _|
  text = "**Usage:**\n"

  SweetieBot.config.prefixes.each do |prefix|
    text += "**#{prefix}**_command <arguments>_\n"
  end

  text += "\n**Available Commands:**\n```\n"

  cmds = CommandDispatcher.help
  wide = cmds.max { |a, b| a[:name].length <=> b[:name].length }[:name].length

  cmds.each do |cmd|
    name = cmd[:name]
    text += "#{name}#{' ' * (wide - name.length)} - "
    text += "(#{cmd[:aliases].join(', ')}) " unless cmd[:aliases].empty?
    text += "#{cmd[:help_text]}.\n"
  end

  text += '```'

  msg.sender.pm text
  msg.message.react '✉️' unless msg.channel.channel_type == :private
end

CommandDispatcher.alias 'h', 'help'
