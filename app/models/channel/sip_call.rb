# frozen_string_literal: true

class Channel::SipCall < ApplicationRecord
  include Channelable

  self.table_name = 'channel_sip_calls'

  belongs_to :sip_trunk

  validates :phone_number, presence: true, uniqueness: true
  validates :sip_trunk_id, presence: true

  def name
    'SIP Voice'
  end

  def voice_enabled?
    true
  end
end
