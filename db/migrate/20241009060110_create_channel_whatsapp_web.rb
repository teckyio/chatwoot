class CreateChannelWhatsappWeb < ActiveRecord::Migration[7.0]
  def change
    create_table :channel_whatsapp_web do |t|
      t.string :uuid
      t.integer :account_id

      t.timestamps
    end
    add_index :channel_whatsapp_web, :uuid, unique: true
  end
end
