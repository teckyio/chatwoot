class Webhooks::WhatsappWebController < ActionController::API
  def process_payload
    Webhooks::WhatsappWebEventsJob.perform_later(params.to_unsafe_hash)
    head :ok
  end
end
