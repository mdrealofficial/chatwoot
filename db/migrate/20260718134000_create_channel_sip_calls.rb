class CreateChannelSipCalls < ActiveRecord::Migration[7.1]
  def change
    create_table :channel_sip_calls do |t|
      t.string :phone_number, null: false
      t.integer :account_id, null: false
      t.bigint :sip_trunk_id, null: false

      t.timestamps
    end

    add_index :channel_sip_calls, :phone_number, unique: true
    add_index :channel_sip_calls, :sip_trunk_id
    add_index :channel_sip_calls, [:account_id, :phone_number]
  end
end
