import ApiClient from './ApiClient';

class WhatsappWebClient extends ApiClient {
  createInstance(accountId) {
    return this.post(`accounts/${accountId}/whatsapp_web/create_instance`);
  }

  getQRCode(accountId, uuid) {
    return this.get(`accounts/${accountId}/whatsapp_web/get_qr_code`, {
      params: { uuid },
    });
  }

  getInstanceStatus(accountId, uuid) {
    return this.get(`accounts/${accountId}/whatsapp_web/get_instance_status`, {
      params: { uuid },
    });
  }

  deleteInstance(accountId, uuid) {
    return this.delete(`accounts/${accountId}/whatsapp_web/delete_instance`, {
      params: { uuid },
    });
  }
}

export default new WhatsappWebClient();
