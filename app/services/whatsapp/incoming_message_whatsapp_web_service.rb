class Whatsapp::IncomingMessageWhatsappWebService
  include ::Whatsapp::IncomingMessageServiceHelpers

  pattr_initialize [:inbox!, :params!]

  def perform
    processed_params

    return if find_message_by_source_id(@processed_params[:messageId]) || message_under_process?

    cache_message_source_id_in_redis
    set_contact
    return unless @contact

    set_conversation
    return if @conversation.nil?

    message = @processed_params
    create_message(message)
    attach_files if params[:attachments].present?
    # attach_location if message_type == 'location'
    @message.save!
  end

  private

  def message_under_process?
    key = format(Redis::RedisKeys::MESSAGE_SOURCE_KEY, id: @processed_params[:messageId])
    Redis::Alfred.get(key)
  end

  def cache_message_source_id_in_redis
    return if @processed_params.try(:[], :messages).blank?

    key = format(Redis::RedisKeys::MESSAGE_SOURCE_KEY, id: @processed_params[:messageId])
    ::Redis::Alfred.setex(key, true)
  end

  def clear_message_source_id_from_redis
    key = format(Redis::RedisKeys::MESSAGE_SOURCE_KEY, id: @processed_params[:messageId])
    ::Redis::Alfred.delete(key)
  end

  def set_contact
    waid = @processed_params[:waId]
    phone_number = @processed_params[:senderPhoneNumber]

    contact_inbox = ::ContactInboxWithContactBuilder.new(
      source_id: waid,
      inbox: inbox,
      contact_attributes: { name: @processed_params[:senderName], phone_number: "+#{phone_number}" }
    ).perform

    @contact_inbox = contact_inbox
    @contact = contact_inbox.contact
  end

  def set_conversation
    # if lock to single conversation is disabled, we will create a new conversation if previous conversation is resolved
    @conversation = if @inbox.lock_to_single_conversation
                      @contact_inbox.conversations.last
                    else
                      @contact_inbox.conversations
                                    .where.not(status: :resolved).last
                    end
    return if @conversation

    @conversation = ::Conversation.create!(conversation_params)
  end

  def create_message(message)
    @message = @conversation.messages.build(
      content: message_content(message),
      account_id: @inbox.account_id,
      inbox_id: @inbox.id,
      message_type: :incoming,
      sender: @contact,
      source_id: message[:messageId]
      # in_reply_to_external_id: @in_reply_to_external_id
    )
  end

  def message_content(message)
    message[:message]
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
        io: Down.download(attachment[:url]),
        filename: attachment[:filename],
        content_type: attachment[:contentType]
      )
      attachment_obj.save!
    end
  end
end
