class CreateSitesBulkRefreshes < ActiveRecord::Migration[7.1]
  def change
    create_table :sites_bulk_refreshes do |t|
      t.belongs_to :site, null: false, foreign_key: true
      t.jsonb :page_data, null: false
      t.string :status, default: "pending", null: false

      t.timestamps
    end
  end
end
