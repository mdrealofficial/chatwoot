# == Schema Information
#
# Table name: sip_trunks
#
#  id                 :bigint           not null, primary key
#  is_default         :boolean          default(FALSE), not null
#  name               :string           not null
#  password           :string           not null
#  port               :integer          default(5060), not null
#  server_host        :string           not null
#  transport          :string           default("udp"), not null
#  username           :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_id         :bigint           not null
#  outbound_caller_id :string
#
# Indexes
#
#  index_sip_trunks_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id) ON DELETE => cascade
#
class SipTrunk < ApplicationRecord
  belongs_to :account

  encrypts :password if Chatwoot.encryption_configured?

  validates :account_id, presence: true
  validates :name, presence: true
  validates :server_host, presence: true
  validates :port, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :transport, presence: true, inclusion: { in: %w[udp tcp tls] }
  validates :username, presence: true
  validates :password, presence: true

  before_save :ensure_single_default

  private

  def ensure_single_default
    if is_default?
      account.sip_trunks.where.not(id: id).update_all(is_default: false)
    end
  end
end
