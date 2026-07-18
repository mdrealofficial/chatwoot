require 'rails_helper'

RSpec.describe SipTrunk, type: :model do
  let(:account) { create(:account) }
  let(:sip_trunk) { create(:sip_trunk, account: account) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(sip_trunk).to be_valid
    end

    it 'is invalid without a name' do
      sip_trunk.name = nil
      expect(sip_trunk).not_to be_valid
    end

    it 'is invalid without a server_host' do
      sip_trunk.server_host = nil
      expect(sip_trunk).not_to be_valid
    end

    it 'is invalid with invalid transport' do
      sip_trunk.transport = 'http'
      expect(sip_trunk).not_to be_valid
    end

    it 'is invalid with non-numeric port' do
      sip_trunk.port = 'abc'
      expect(sip_trunk).not_to be_valid
    end
  end

  describe 'single default callback' do
    it 'ensures only one trunk is set as default per account' do
      trunk1 = create(:sip_trunk, account: account, is_default: true)
      trunk2 = create(:sip_trunk, account: account, is_default: false)

      expect(trunk1.reload.is_default).to be true
      expect(trunk2.reload.is_default).to be false

      trunk2.update!(is_default: true)

      expect(trunk1.reload.is_default).to be false
      expect(trunk2.reload.is_default).to be true
    end
  end
end
