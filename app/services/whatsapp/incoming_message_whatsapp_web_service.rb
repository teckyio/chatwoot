class Whatsapp::IncomingMessageWhatsappWebService
  pattr_initialize [:inbox!, :params!]

  def perform
    set_contact
    set_conversation
    return if @conversation.nil?

    @message = @conversation.messages.create(
      content: message_content,
      account_id: @inbox.account_id,
      inbox_id: @inbox.id,
      message_type: :incoming,
      sender: @contact,
      source_id: params[:messageId].to_s,
      content_attributes: content_attributes
    )
    attach_files if params[:attachments].present?
  end

  private

  def set_contact
    contact_params = {
      name: params[:senderName],
      phone_number: params[:senderPhoneNumber],
      account_id: @inbox.account_id,
      source_id: params[:senderPhoneNumber]
    }
    @contact = ::ContactBuilder.new(contact_params).perform
  end

  def set_conversation
    @conversation = ::Conversation.find_or_create_by!(
      account_id: @inbox.account_id,
      inbox_id: @inbox.id,
      contact_id: @contact.id,
      status: ::Conversation.statuses[:open]
    )
  end

  def message_content
    params[:message]
  end

  def content_attributes
    {
      whatsapp: {
        timestamp: params[:timestamp]
      }
    }
  end

  def attach_files
    params[:attachments].each do |attachment|
      attachment_obj = @message.attachments.new(
        account_id: @inbox.account_id,
        file_type: attachment[:contentType]
      )
      attachment_obj.file.attach(
        io: URI.open(attachment[:url]),
        filename: attachment[:filename],
        content_type: attachment[:contentType]
      )
      attachment_obj.save!
    end
  end
end
