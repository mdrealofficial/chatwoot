class CreateSipTrunks < ActiveRecord::Migration[7.1]
  def change
    create_table :sip_trunks do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.string :server_host, null: false
      t.integer :port, default: 5060, null: false
      t.string :transport, default: 'udp', null: false
      t.string :username, null: false
      t.string :password, null: false
      t.string :outbound_caller_id
      t.boolean :is_default, default: false, null: false

      t.timestamps
    end
  end
end
