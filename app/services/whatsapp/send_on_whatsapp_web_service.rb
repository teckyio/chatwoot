class Whatsapp::SendOnWhatsappWebService < Base::SendOnChannelService
  private

  def channel_class
    Channel::WhatsappWeb
  end

  def perform_reply
    message_id = channel.send_message(
      message.conversation.contact_inbox.source_id,
      message
    )

    message.update!(source_id: message_id) if message_id
  end

  def attachments
    message.attachments.map(&:download_url)
  end

  def inbox
    @inbox ||= message.inbox
  end

  def channel
    @channel ||= inbox.channel
  end

  def outgoing_message?
    message.outgoing? || message.template?
  end
end
