import ApiClient from './ApiClient';

class WhatsappWebClient extends ApiClient {
  createInstance(accountId) {
    return this.post(`accounts/${accountId}/whatsapp_web/instances`);
  }

  getQRCode(accountId, uuid) {
    return this.get(`accounts/${accountId}/whatsapp_web/instances/${uuid}/qr`);
  }

  getInstanceStatus(accountId, uuid) {
    return this.get(
      `accounts/${accountId}/whatsapp_web/instances/${uuid}/status`
    );
  }

  deleteInstance(accountId, uuid) {
    return this.delete(`accounts/${accountId}/whatsapp_web/instances/${uuid}`);
  }
}

export default new WhatsappWebClient();
