# frozen_string_literal: true

class User < ActiveRecord::Base
  FORCED_ADMIN_IDS = %w[128567958086615040].freeze

  def self.admin?(usr_id)
    User::FORCED_ADMIN_IDS.include? usr_id.to_s
  end
end
