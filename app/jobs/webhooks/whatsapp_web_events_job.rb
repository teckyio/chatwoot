class Webhooks::WhatsappWebEventsJob < ApplicationJob
  queue_as :default

  def perform(params = {})
    channel = Channel::WhatsappWeb.find_by(uuid: params[:uuid])
    return if channel_is_inactive?(channel)

    Whatsapp::IncomingMessageWhatsappWebService.new(inbox: channel.inbox, params: params).perform
  end

  private

  def channel_is_inactive?(channel)
    return true if channel.blank?
    return true unless channel.account.active?

    false
  end
end
