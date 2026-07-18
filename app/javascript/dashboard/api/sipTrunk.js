/* global axios */

import ApiClient from './ApiClient';

class SipTrunk extends ApiClient {
  constructor() {
    super('sip_trunks', { accountScoped: true });
  }
}

export default new SipTrunk();
