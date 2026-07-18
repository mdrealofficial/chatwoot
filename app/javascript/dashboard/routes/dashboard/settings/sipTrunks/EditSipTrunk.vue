<script setup>
import { useAlert } from 'dashboard/composables';
import { ref, onMounted } from 'vue';
import { useStore } from 'dashboard/composables/store';
import NextButton from 'dashboard/components-next/button/Button.vue';
import Modal from '../../../../components/Modal.vue';

const props = defineProps({
  id: {
    type: [Number, String],
    required: true,
  },
  trunk: {
    type: Object,
    required: true,
  },
  onClose: {
    type: Function,
    default: () => {},
  },
});

const store = useStore();

const show = ref(true);
const loading = ref(false);

const name = ref('');
const serverHost = ref('');
const port = ref(5060);
const transport = ref('udp');
const username = ref('');
const password = ref('');
const outboundCallerId = ref('');
const isDefault = ref(false);

onMounted(() => {
  name.value = props.trunk.name;
  serverHost.value = props.trunk.server_host;
  port.value = props.trunk.port;
  transport.value = props.trunk.transport;
  username.value = props.trunk.username;
  outboundCallerId.value = props.trunk.outbound_caller_id || '';
  isDefault.value = props.trunk.is_default;
});

const editSipTrunk = async () => {
  if (!name.value || !serverHost.value || !username.value) {
    useAlert('Please fill in all required fields.');
    return;
  }

  loading.value = true;
  try {
    const payload = {
      id: props.id,
      name: name.value,
      server_host: serverHost.value,
      port: port.value,
      transport: transport.value,
      username: username.value,
      outbound_caller_id: outboundCallerId.value,
      is_default: isDefault.value,
    };
    if (password.value) {
      payload.password = password.value;
    }
    await store.dispatch('updateSipTrunk', payload);
    useAlert('SIP Trunk updated successfully.');
    props.onClose();
  } catch (error) {
    const errorMessage = error?.message || 'Failed to update SIP Trunk.';
    useAlert(errorMessage);
  } finally {
    loading.value = false;
  }
};
</script>

<template>
  <Modal v-model:show="show" :on-close="onClose">
    <div class="flex flex-col h-auto overflow-auto">
      <woot-modal-header
        header-title="Edit SIP Trunk"
        header-content="Update your SIP trunk credentials."
      />
      <form class="flex flex-col w-full @submit.prevent" @submit.prevent="editSipTrunk()">
        <div class="w-full">
          <label>
            Trunk Name *
            <input
              v-model="name"
              type="text"
              placeholder="e.g., Sales SIP, Support SIP"
              required
            />
          </label>

          <div class="flex gap-4">
            <label class="w-2/3">
              SIP Server Host *
              <input
                v-model="serverHost"
                type="text"
                placeholder="sip.example.com"
                required
              />
            </label>
            <label class="w-1/3">
              Port *
              <input
                v-model="port"
                type="number"
                placeholder="5060"
                required
              />
            </label>
          </div>

          <label>
            Transport Protocol *
            <select v-model="transport" required>
              <option value="udp">UDP</option>
              <option value="tcp">TCP</option>
              <option value="tls">TLS (Secure)</option>
            </select>
          </label>

          <label>
            Username *
            <input
              v-model="username"
              type="text"
              placeholder="SIP username"
              required
            />
          </label>

          <label>
            Password (Leave blank to keep current)
            <input
              v-model="password"
              type="password"
              placeholder="Enter new password"
            />
          </label>

          <label>
            Outbound Caller ID
            <input
              v-model="outboundCallerId"
              type="text"
              placeholder="+1234567890"
            />
          </label>

          <div class="flex items-center gap-2 mb-4">
            <input
              id="set-default"
              v-model="isDefault"
              type="checkbox"
            />
            <label for="set-default" class="mb-0 cursor-pointer font-medium text-sm text-n-slate-12">
              Set as Default Trunk
            </label>
          </div>
        </div>

        <div class="flex items-center justify-end gap-3 py-3 w-full border-t border-n-slate-3">
          <NextButton
            label="Cancel"
            slate
            type="button"
            @click="onClose"
          />
          <NextButton
            label="Update Trunk"
            type="submit"
            :is-loading="loading"
          />
        </div>
      </form>
    </div>
  </Modal>
</template>
