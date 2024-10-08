<script>
import PageHeader from '../../SettingsSubPageHeader.vue';
export default {
  components: {
    PageHeader,
  },
  data() {
    return {
      provider: 'whatsapp_cloud',
    };
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
      <label>
        {{ $t('INBOX_MGMT.ADD.WHATSAPP_WEB.QRCODE.LABEL') }}
      </label>
    </div>
  </div>
</template>
