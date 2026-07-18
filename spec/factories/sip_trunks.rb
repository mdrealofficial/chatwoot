FactoryBot.define do
  factory :sip_trunk do
    association :account
    name { 'Sales SIP' }
    server_host { 'sip.example.com' }
    port { 5060 }
    transport { 'udp' }
    username { 'sales_sip_user' }
    password { 'secure_password' }
    outbound_caller_id { '+1234567890' }
    is_default { false }
  end
end
