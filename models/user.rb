# frozen_string_literal: true

# User data class used only to check if a user is admin or not
# @note May be used for other features later down the line.
class User < ActiveRecord::Base
  validates :name, presence: true

  # Discord User IDs of the users that will have the admin permissions over the bot
  # regardless of anything.
  FORCED_ADMIN_IDS = %w[128567958086615040].freeze

  # Checks if the given user ID is admin or not
  # @note Pass only the number, not the `<@...>` mention handle.
  # @param usr_id [Number] Discord User ID.
  # @return [Boolean] whether the user is admin or not.
  def self.admin?(usr_id)
    return true if User::FORCED_ADMIN_IDS.include? usr_id.to_s
    return true if SweetieBot.config.discord.administrators.include? usr_id.to_i

    false
  end
end
