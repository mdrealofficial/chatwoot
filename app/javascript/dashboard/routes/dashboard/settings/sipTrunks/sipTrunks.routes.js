import { frontendURL } from '../../../../helper/URLHelper';
import {
  ROLES,
  CONVERSATION_PERMISSIONS,
} from 'dashboard/constants/permissions.js';
import SettingsWrapper from '../SettingsWrapper.vue';
import SipTrunksHome from './Index.vue';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/sip-trunks'),
      component: SettingsWrapper,
      children: [
        {
          path: '',
          redirect: to => {
            return { name: 'sip_trunks_list', params: to.params };
          },
        },
        {
          path: 'list',
          name: 'sip_trunks_list',
          meta: {
            permissions: [...ROLES],
          },
          component: SipTrunksHome,
        },
      ],
    },
  ],
};
