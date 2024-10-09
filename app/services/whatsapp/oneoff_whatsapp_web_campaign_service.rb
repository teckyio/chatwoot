class Whatsapp::OneoffWhatsappWebCampaignService
  pattr_initialize [:campaign!]

  def perform
    raise "Invalid campaign #{campaign.id}" if campaign.inbox.inbox_type != 'WhatsApp Unofficial' || !campaign.one_off?
    raise 'Completed Campaign' if campaign.completed?

    # marks campaign completed so that other jobs won't pick it up
    campaign.completed!

    audience_label_ids = campaign.audience.select { |audience| audience['type'] == 'Label' }.pluck('id')
    audience_labels = campaign.account.labels.where(id: audience_label_ids).pluck(:title)
    process_audience(audience_labels)
  end

  private

  delegate :inbox, to: :campaign
  delegate :channel, to: :inbox

  def process_audience(audience_labels)
    campaign.account.contacts.tagged_with(audience_labels, any: true).each do |contact|
      next if contact.phone_number.blank?

      send_message(to: contact, content: campaign.message)
    end
  end

  def send_message(to:, content:)
    Whatsapp::SendOnWhatsappWebService.new(message: build_message(to, content)).perform
  end

  def build_message(to, content)
    Message.new(
      account: campaign.account,
      inbox: inbox,
      conversation: find_or_create_conversation(to),
      message_type: :outgoing,
      content: content
    )
  end

  def find_or_create_conversation(contact)
    Conversation.find_or_create_by!(
      account_id: campaign.account.id,
      inbox_id: inbox.id,
      contact_id: contact.id,
      status: ::Conversation.statuses[:open]
    )
  end
end
