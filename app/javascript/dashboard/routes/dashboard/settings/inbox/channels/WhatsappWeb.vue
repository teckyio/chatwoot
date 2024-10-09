<script>
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';
import QRCode from 'qrcode.vue';
import PageHeader from '../../SettingsSubPageHeader.vue';
import WhatsappWebClient from '../../../../../api/whatsappWebClient';

export default {
  components: {
    PageHeader,
    QRCode,
  },
  data() {
    return {
      isCreating: false,
      qrCode: null,
      instanceUuid: null,
      instanceStatus: null,
      pollingInterval: null,
    };
  },
  computed: {
    ...mapGetters({
      accountId: 'getCurrentAccountId',
    }),
  },
  beforeDestroy() {
    this.stopPolling();
  },
  methods: {
    async createInstance() {
      this.isCreating = true;
      try {
        const { data } = await WhatsappWebClient.createInstance(this.accountId);
        this.instanceUuid = data.uuid;
        this.startPolling();
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error('Error create instance:', error);
        useAlert(this.$t('INBOX_MGMT.ADD.WHATSAPP_WEB.API_ERROR'));
      } finally {
        this.isCreating = false;
      }
    },
    async getQRCode() {
      try {
        const { data } = await WhatsappWebClient.getQRCode(this.instanceUuid);
        this.qrCode = data.qrCode;
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error('Error fetching QR code:', error);
      }
    },
    async getInstanceStatus() {
      try {
        const { data } = await WhatsappWebClient.getInstanceStatus(
          this.instanceUuid
        );
        this.instanceStatus = data.status;
        if (this.instanceStatus === 'READY') {
          this.stopPolling();
          this.createInbox();
        }
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error('Error fetching instance status:', error);
      }
    },
    startPolling() {
      this.pollingInterval = setInterval(() => {
        this.getQRCode();
        this.getInstanceStatus();
      }, 2000);
    },
    stopPolling() {
      clearInterval(this.pollingInterval);
    },
    async createInbox() {
      try {
        await this.$store.dispatch('inboxes/createWhatsAppWebInbox', {
          uuid: this.instanceUuid,
        });
        this.$router.push({ name: 'settings_inboxes' });
      } catch (error) {
        useAlert(this.$t('INBOX_MGMT.ADD.WHATSAPP_WEB.INBOX_ERROR'));
      }
    },
  },
};
</script>

<template>
  <div
    class="border border-slate-25 dark:border-slate-800/60 bg-white dark:bg-slate-900 h-full p-6 w-full max-w-full md:w-3/4 md:max-w-[75%] flex-shrink-0 flex-grow-0"
  >
    <PageHeader
      :header-title="$t('INBOX_MGMT.ADD.WHATSAPP_WEB.TITLE')"
      :header-content="$t('INBOX_MGMT.ADD.WHATSAPP_WEB.DESC')"
    />
    <div class="w-[65%] flex-shrink-0 flex-grow-0 max-w-[65%]">
      <button
        v-if="!instanceUuid"
        class="button button--primary"
        :disabled="isCreating"
        @click="createInstance"
      >
        {{ $t('INBOX_MGMT.ADD.WHATSAPP_WEB.CREATE_BUTTON') }}
      </button>
      <div v-else-if="!qrCode" class="mt-4">
        <p>{{ $t('INBOX_MGMT.ADD.WHATSAPP_WEB.LOADING_QR') }}</p>
      </div>
      <div v-else class="mt-4">
        <h3>{{ $t('INBOX_MGMT.ADD.WHATSAPP_WEB.QRCODE.LABEL') }}</h3>
        <QRCode :value="qrCode" :size="256" level="M" />
        <p class="mt-2">
          {{ $t('INBOX_MGMT.ADD.WHATSAPP_WEB.QRCODE.DESCRIPTION') }}
        </p>
      </div>
      <div v-if="instanceStatus" class="mt-4">
        <h3>{{ $t('INBOX_MGMT.ADD.WHATSAPP_WEB.STATUS') }}</h3>
        <p>{{ instanceStatus }}</p>
      </div>
    </div>
  </div>
</template>
