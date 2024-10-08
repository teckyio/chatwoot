class Api::V1::WhatsappWebController < Api::V1::BaseController
  def create_instance
    response = WhatsappWebService.create_instance(Current.account.id)
    render json: response
  end

  def get_qr_code
    response = WhatsappWebService.get_qr_code(Current.account.id, params[:uuid])
    render json: response
  end

  def get_instance_status
    response = WhatsappWebService.get_instance_status(Current.account.id, params[:uuid])
    render json: response
  end

  def delete_instance
    response = WhatsappWebService.delete_instance(Current.account.id, params[:uuid])
    render json: response
  end
end
