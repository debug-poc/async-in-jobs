class CreateSitesPages < ActiveRecord::Migration[7.1]
  def change
    create_table :sites_pages do |t|
      t.belongs_to :site, null: false, foreign_key: true
      t.string :url, null: false
      t.text :content
      t.string :refresh_status, default: "pending", null: false
      t.datetime :refresh_queued_at
      t.datetime :refreshed_at
      t.timestamps
    end
  end
end
