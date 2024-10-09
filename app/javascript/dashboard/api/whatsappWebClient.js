/* global axios */
import ApiClient from './ApiClient';

class WhatsappWebClient extends ApiClient {
  constructor() {
    super('whatsapp_web', { accountScoped: true });
  }

  createInstance() {
    return axios.post(`${this.url}/create_instance`);
  }

  getQRCode(uuid) {
    return axios.get(`${this.url}/get_qr_code`, {
      params: { uuid },
    });
  }

  getInstanceStatus(uuid) {
    return axios.get(`${this.url}/get_instance_status`, {
      params: { uuid },
    });
  }

  deleteInstance(uuid) {
    return axios.delete(`${this.url}/delete_instance`, {
      params: { uuid },
    });
  }
}

export default new WhatsappWebClient();
