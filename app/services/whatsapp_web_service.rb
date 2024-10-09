class WhatsappWebService
  include HTTParty
  base_uri ENV.fetch('WHATSAPP_WEB_SERVICE_URL', nil)

  def self.create_instance(account_id)
    post('/instances', body: {
      'accountId' => account_id
    }.to_json, headers: {
      'Content-Type' => 'application/json'
    })
  end

  def self.get_qr_code(_account_id, uuid)
    get("/instances/#{uuid}/qr")
  end

  def self.get_instance_status(_account_id, uuid)
    get("/instances/#{uuid}/status")
  end

  def self.delete_instance(_account_id, uuid)
    delete("/instances/#{uuid}")
  end
end
