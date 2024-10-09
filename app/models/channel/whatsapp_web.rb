# == Schema Information
#
# Table name: channel_whatsapp_web
#
#  id         :bigint           not null, primary key
#  uuid       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :integer
#
# Indexes
#
#  index_channel_whatsapp_web_on_uuid  (uuid) UNIQUE
#

class Channel::WhatsappWeb < ApplicationRecord
  include Channelable

  self.table_name = 'channel_whatsapp_web'
  EDITABLE_ATTRS = [:uuid].freeze

  validates :uuid, presence: true, uniqueness: true

  def name
    'WhatsApp Unofficial'
  end

  def provider_service
    @provider_service ||= Whatsapp::Providers::WhatsappWebService.new(whatsapp_channel: self)
  end

  def messaging_window_enabled?
    false
  end

  delegate :send_message, to: :provider_service
  delegate :send_template, to: :provider_service
  delegate :sync_templates, to: :provider_service
  delegate :media_url, to: :provider_service
end
