class WhatsappWebService
  include HTTParty
  base_uri ENV['WHATSAPP_WEB_SERVICE_URL']

  def self.create_instance(account_id)
    post("/accounts/#{account_id}/whatsapp_web/instances", body: {})
  end

  def self.get_qr_code(account_id, uuid)
    get("/accounts/#{account_id}/whatsapp_web/instances/#{uuid}/qr")
  end

  def self.get_instance_status(account_id, uuid)
    get("/accounts/#{account_id}/whatsapp_web/instances/#{uuid}/status")
  end

  def self.delete_instance(account_id, uuid)
    delete("/accounts/#{account_id}/whatsapp_web/instances/#{uuid}")
  end
end
