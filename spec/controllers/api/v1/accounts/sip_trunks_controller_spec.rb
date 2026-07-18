require 'rails_helper'

RSpec.describe 'Sip Trunks API', type: :request do
  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:agent) { create(:user, account: account, role: :agent) }
  let!(:sip_trunk) { create(:sip_trunk, account: account) }

  describe 'GET /api/v1/accounts/{account.id}/sip_trunks' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        get "/api/v1/accounts/#{account.id}/sip_trunks"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated administrator' do
      it 'returns all sip_trunks related to the account' do
        get "/api/v1/accounts/#{account.id}/sip_trunks",
            headers: admin.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:success)
        response_body = response.parsed_body
        expect(response_body.first['name']).to eq(sip_trunk.name)
        expect(response_body.first['server_host']).to eq(sip_trunk.server_host)
      end
    end
  end

  describe 'GET /api/v1/accounts/{account.id}/sip_trunks/:id' do
    context 'when it is an authenticated administrator' do
      it 'shows the custom filter' do
        get "/api/v1/accounts/#{account.id}/sip_trunks/#{sip_trunk.id}",
            headers: admin.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['name']).to eq(sip_trunk.name)
      end
    end
  end

  describe 'POST /api/v1/accounts/{account.id}/sip_trunks' do
    let(:payload) do
      { sip_trunk: {
        name: 'Support SIP',
        server_host: 'sip.support.com',
        port: 5061,
        transport: 'tls',
        username: 'support_sip_user',
        password: 'super_secure_pass',
        outbound_caller_id: '+1234567890',
        is_default: true
      } }
    end

    context 'when it is an authenticated agent' do
      it 'returns unauthorized' do
        post "/api/v1/accounts/#{account.id}/sip_trunks",
             headers: agent.create_new_auth_token,
             params: payload,
             as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated administrator' do
      it 'creates the sip trunk' do
        post "/api/v1/accounts/#{account.id}/sip_trunks",
             headers: admin.create_new_auth_token,
             params: payload,
             as: :json

        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response['name']).to eq 'Support SIP'
        expect(json_response['server_host']).to eq 'sip.support.com'
      end
    end
  end

  describe 'PUT /api/v1/accounts/{account.id}/sip_trunks/:id' do
    let(:payload) { { sip_trunk: { name: 'Updated Name' } } }

    context 'when it is an authenticated administrator' do
      it 'updates the sip trunk' do
        put "/api/v1/accounts/#{account.id}/sip_trunks/#{sip_trunk.id}",
            headers: admin.create_new_auth_token,
            params: payload,
            as: :json

        expect(response).to have_http_status(:ok)
        expect(sip_trunk.reload.name).to eq 'Updated Name'
      end
    end
  end

  describe 'DELETE /api/v1/accounts/{account.id}/sip_trunks/:id' do
    context 'when it is an authenticated administrator' do
      it 'deletes the sip trunk' do
        delete "/api/v1/accounts/#{account.id}/sip_trunks/#{sip_trunk.id}",
               headers: admin.create_new_auth_token,
               as: :json

        expect(response).to have_http_status(:no_content)
        expect { sip_trunk.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
