<script setup>
import { useAlert } from 'dashboard/composables';
import AddSipTrunk from './AddSipTrunk.vue';
import EditSipTrunk from './EditSipTrunk.vue';
import SettingsLayout from '../SettingsLayout.vue';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';
import { computed, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStoreGetters, useStore } from 'dashboard/composables/store';
import { picoSearch } from '@scmmishra/pico-search';

import Button from 'dashboard/components-next/button/Button.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import {
  BaseTable,
  BaseTableRow,
  BaseTableCell,
} from 'dashboard/components-next/table';

defineOptions({
  name: 'SipTrunkSettings',
});

const getters = useStoreGetters();
const store = useStore();
const { t } = useI18n();

const showAddPopup = ref(false);
const loading = ref({});
const showEditPopup = ref(false);
const showDeleteConfirmationPopup = ref(false);
const activeTrunk = ref({});

const searchQuery = ref('');

const records = computed(() => getters.getSipTrunks.value);

const filteredRecords = computed(() => {
  const query = searchQuery.value.trim();
  if (!query) return records.value;
  return picoSearch(records.value, query, [
    { name: 'name', weight: 4 },
    'server_host',
    'username',
  ]);
});
const uiFlags = computed(() => getters.getSipTrunksUIFlags.value);

const deleteConfirmText = computed(
  () => `Delete ${activeTrunk.value.name}`
);

const deleteRejectText = computed(
  () => `Cancel`
);

const deleteMessage = computed(() => {
  return `Are you sure you want to delete ${activeTrunk.value.name}?`;
});

const fetchSipTrunks = async () => {
  try {
    await store.dispatch('getSipTrunks');
  } catch (error) {
    // Ignore Error
  }
};

onMounted(() => {
  fetchSipTrunks();
});

const showAlertMessage = message => {
  loading[activeTrunk.value.id] = false;
  activeTrunk.value = {};
  useAlert(message);
};

const openAddPopup = () => {
  showAddPopup.value = true;
};
const hideAddPopup = () => {
  showAddPopup.value = false;
};

const openEditPopup = trunk => {
  showEditPopup.value = true;
  activeTrunk.value = trunk;
};
const hideEditPopup = () => {
  showEditPopup.value = false;
};

const openDeletePopup = trunk => {
  showDeleteConfirmationPopup.value = true;
  activeTrunk.value = trunk;
};

const closeDeletePopup = () => {
  showDeleteConfirmationPopup.value = false;
};

const deleteSipTrunk = async id => {
  try {
    await store.dispatch('deleteSipTrunk', id);
    showAlertMessage('SIP Trunk deleted successfully.');
  } catch (error) {
    const errorMessage = error?.message || 'Failed to delete SIP Trunk.';
    showAlertMessage(errorMessage);
  }
};

const confirmDeletion = () => {
  loading[activeTrunk.value.id] = true;
  closeDeletePopup();
  deleteSipTrunk(activeTrunk.value.id);
};

const tableHeaders = computed(() => {
  return [
    'Name',
    'Host',
    'Port',
    'Transport',
    'Username',
    'Outbound Caller ID',
    'Default',
    'Actions',
  ];
});
</script>

<template>
  <SettingsLayout
    :is-loading="uiFlags.fetchingList"
    loading-message="Loading SIP Trunks..."
    :no-records-found="!records.length"
    no-records-message="No SIP Trunks found."
  >
    <template #header>
      <BaseSettingsHeader
        v-model:search-query="searchQuery"
        title="SIP Trunks"
        description="Configure and manage your SIP trunk credentials for making and receiving voice calls."
        search-placeholder="Search SIP Trunks..."
      >
        <template v-if="records?.length" #count>
          <span class="text-body-main text-n-slate-11">
            {{ records.length }} found
          </span>
        </template>
        <template #actions>
          <Button
            label="Add SIP Trunk"
            size="sm"
            @click="openAddPopup"
          />
        </template>
      </BaseSettingsHeader>
    </template>

    <template #body>
      <BaseTable
        :headers="tableHeaders"
        :items="filteredRecords"
        no-data-message="No SIP Trunks configured."
      >
        <template #header-0>{{ tableHeaders[0] }}</template>
        <template #header-1>{{ tableHeaders[1] }}</template>
        <template #header-2>{{ tableHeaders[2] }}</template>
        <template #header-3>{{ tableHeaders[3] }}</template>
        <template #header-4>{{ tableHeaders[4] }}</template>
        <template #header-5>{{ tableHeaders[5] }}</template>
        <template #header-6>{{ tableHeaders[6] }}</template>
        <template #header-7>{{ tableHeaders[7] }}</template>

        <template #row="{ items }">
          <BaseTableRow
            v-for="trunk in items"
            :key="trunk.id"
            :item="trunk"
          >
            <template #default>
              <BaseTableCell>
                <span class="text-heading-3 text-n-slate-12 truncate block">
                  {{ trunk.name }}
                </span>
              </BaseTableCell>
              <BaseTableCell>{{ trunk.server_host }}</BaseTableCell>
              <BaseTableCell>{{ trunk.port }}</BaseTableCell>
              <BaseTableCell>
                <span class="uppercase text-xs font-semibold px-2 py-0.5 rounded bg-n-slate-3 text-n-slate-11">
                  {{ trunk.transport }}
                </span>
              </BaseTableCell>
              <BaseTableCell>{{ trunk.username }}</BaseTableCell>
              <BaseTableCell>{{ trunk.outbound_caller_id || '-' }}</BaseTableCell>
              <BaseTableCell>
                <Icon
                  v-if="trunk.is_default"
                  class="size-5 text-n-green-11"
                  icon="i-lucide-check-circle-2"
                />
                <span v-else class="text-n-slate-10">-</span>
              </BaseTableCell>
              <BaseTableCell align="end" class="w-24">
                <div class="flex gap-3 justify-end flex-shrink-0">
                  <Button
                    v-tooltip.top="'Edit'"
                    icon="i-woot-edit-pen"
                    slate
                    sm
                    @click="openEditPopup(trunk)"
                  />
                  <Button
                    v-tooltip.top="'Delete'"
                    icon="i-woot-bin"
                    slate
                    sm
                    class="hover:enabled:text-n-ruby-11 hover:enabled:bg-n-ruby-2"
                    :is-loading="loading[trunk.id]"
                    @click="openDeletePopup(trunk)"
                  />
                </div>
              </BaseTableCell>
            </template>
          </BaseTableRow>
        </template>
      </BaseTable>
    </template>

    <woot-modal v-model:show="showAddPopup" :on-close="hideAddPopup">
      <AddSipTrunk :on-close="hideAddPopup" />
    </woot-modal>

    <woot-modal v-model:show="showEditPopup" :on-close="hideEditPopup">
      <EditSipTrunk
        v-if="showEditPopup"
        :id="activeTrunk.id"
        :trunk="activeTrunk"
        :on-close="hideEditPopup"
      />
    </woot-modal>

    <woot-delete-modal
      v-model:show="showDeleteConfirmationPopup"
      :on-close="closeDeletePopup"
      :on-confirm="confirmDeletion"
      title="Delete SIP Trunk"
      :message="deleteMessage"
      confirm-text="Delete"
      reject-text="Cancel"
    />
  </SettingsLayout>
</template>
