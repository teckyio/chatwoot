class Whatsapp::Providers::WhatsappWebService
  def initialize(whatsapp_channel:)
    @whatsapp_channel = whatsapp_channel
  end

  def send_message(phone_number, message)
    response = HTTParty.post(
      "#{api_base_path}/send-message",
      headers: api_headers,
      body: {
        uuid: @whatsapp_channel.uuid,
        phone_number: phone_number,
        message: message.content,
        attachments: message.attachments.map { |a| { url: a.file_url, filename: a.file.filename } }
      }.to_json
    )

    process_response(response)
  end

  def send_template(phone_number, template_info)
    # Implement template sending if supported by wweb.js
    raise NotImplementedError, 'Template sending is not supported for WhatsappWeb channels'
  end

  def sync_templates
    # No templates to sync for WhatsappWeb channels
  end

  def media_url(media_id)
    "#{api_base_path}/media/#{@whatsapp_channel.uuid}/#{media_id}"
  end

  def api_headers
    {
      'Content-Type' => 'application/json',
      'X-API-KEY' => ENV.fetch('WHATSAPP_WEB_API_KEY', nil)
    }
  end

  private

  def api_base_path
    ENV.fetch('WHATSAPP_WEB_API_URL', 'http://localhost:3000/api/v1')
  end

  def process_response(response)
    if response.success?
      response['messageId']
    else
      Rails.logger.error response.body
      nil
    end
  end
end
