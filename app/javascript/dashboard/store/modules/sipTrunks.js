import { throwErrorMessage } from 'dashboard/store/utils/api';
import * as MutationHelpers from 'shared/helpers/vuex/mutationHelpers';
import * as types from '../mutation-types';
import SipTrunkAPI from '../../api/sipTrunk';

const state = {
  records: [],
  uiFlags: {
    fetchingList: false,
    fetchingItem: false,
    creatingItem: false,
    updatingItem: false,
    deletingItem: false,
  },
};

const getters = {
  getSipTrunks(_state) {
    return _state.records;
  },
  getSipTrunksUIFlags(_state) {
    return _state.uiFlags;
  },
};

const actions = {
  getSipTrunks: async function getSipTrunks({ commit }) {
    commit(types.default.SET_SIP_TRUNK_UI_FLAG, { fetchingList: true });
    try {
      const response = await SipTrunkAPI.get();
      commit(types.default.SET_SIP_TRUNK, response.data);
      commit(types.default.SET_SIP_TRUNK_UI_FLAG, { fetchingList: false });
    } catch (error) {
      commit(types.default.SET_SIP_TRUNK_UI_FLAG, { fetchingList: false });
    }
  },

  createSipTrunk: async function createSipTrunk({ commit }, sipTrunkObj) {
    commit(types.default.SET_SIP_TRUNK_UI_FLAG, { creatingItem: true });
    try {
      const response = await SipTrunkAPI.create(sipTrunkObj);
      commit(types.default.ADD_SIP_TRUNK, response.data);
      commit(types.default.SET_SIP_TRUNK_UI_FLAG, { creatingItem: false });
      return response.data;
    } catch (error) {
      commit(types.default.SET_SIP_TRUNK_UI_FLAG, { creatingItem: false });
      return throwErrorMessage(error);
    }
  },

  updateSipTrunk: async function updateSipTrunk({ commit }, { id, ...sipTrunkObj }) {
    commit(types.default.SET_SIP_TRUNK_UI_FLAG, { updatingItem: true });
    try {
      const response = await SipTrunkAPI.update(id, sipTrunkObj);
      commit(types.default.EDIT_SIP_TRUNK, response.data);
      commit(types.default.SET_SIP_TRUNK_UI_FLAG, { updatingItem: false });
      return response.data;
    } catch (error) {
      commit(types.default.SET_SIP_TRUNK_UI_FLAG, { updatingItem: false });
      return throwErrorMessage(error);
    }
  },

  deleteSipTrunk: async function deleteSipTrunk({ commit }, id) {
    commit(types.default.SET_SIP_TRUNK_UI_FLAG, { deletingItem: true });
    try {
      await SipTrunkAPI.delete(id);
      commit(types.default.DELETE_SIP_TRUNK, id);
      commit(types.default.SET_SIP_TRUNK_UI_FLAG, { deletingItem: false });
      return id;
    } catch (error) {
      commit(types.default.SET_SIP_TRUNK_UI_FLAG, { deletingItem: false });
      return throwErrorMessage(error);
    }
  },
};

const mutations = {
  [types.default.SET_SIP_TRUNK_UI_FLAG](_state, data) {
    _state.uiFlags = {
      ..._state.uiFlags,
      ...data,
    };
  },

  [types.default.SET_SIP_TRUNK]: MutationHelpers.set,
  [types.default.ADD_SIP_TRUNK]: MutationHelpers.create,
  [types.default.EDIT_SIP_TRUNK]: MutationHelpers.update,
  [types.default.DELETE_SIP_TRUNK]: MutationHelpers.destroy,
};

export default {
  state,
  getters,
  actions,
  mutations,
};
