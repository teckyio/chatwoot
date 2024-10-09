class Webhooks::WhatsappEventsJob < ApplicationJob
  queue_as :low

  def perform(params = {})
    channel = find_channel(params)
    return if channel_is_inactive?(channel)

    case channel
    when Channel::Whatsapp
      process_whatsapp_channel(channel, params)
    when Channel::WhatsappWeb
      Webhooks::WhatsappWebEventsJob.perform_later(params)
    end
  end

  private

  def channel_is_inactive?(channel)
    return true if channel.blank?
    return true if channel.is_a?(Channel::Whatsapp) && channel.reauthorization_required?
    return true unless channel.account.active?

    false
  end

  def find_channel(params)
    if params[:uuid].present?
      Channel::WhatsappWeb.find_by(uuid: params[:uuid])
    else
      find_channel_from_whatsapp_business_payload(params)
    end
  end

  def find_channel_from_whatsapp_business_payload(params)
    return get_channel_from_wb_payload(params) if params[:object] == 'whatsapp_business_account'

    find_channel_by_url_param(params)
  end

  def find_channel_by_url_param(params)
    return unless params[:phone_number]

    Channel::Whatsapp.find_by(phone_number: params[:phone_number])
  end

  def get_channel_from_wb_payload(wb_params)
    phone_number = "+#{wb_params[:entry].first[:changes].first.dig(:value, :metadata, :display_phone_number)}"
    phone_number_id = wb_params[:entry].first[:changes].first.dig(:value, :metadata, :phone_number_id)
    channel = Channel::Whatsapp.find_by(phone_number: phone_number)
    return channel if channel && channel.provider_config['phone_number_id'] == phone_number_id
  end

  def process_whatsapp_channel(channel, params)
    case channel.provider
    when 'whatsapp_cloud'
      Whatsapp::IncomingMessageWhatsappCloudService.new(inbox: channel.inbox, params: params).perform
    else
      Whatsapp::IncomingMessageService.new(inbox: channel.inbox, params: params).perform
    end
  end
end
