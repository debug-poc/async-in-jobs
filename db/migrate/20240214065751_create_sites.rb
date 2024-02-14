class CreateSites < ActiveRecord::Migration[7.1]
  def change
    create_table :sites do |t|
      t.column :name, :string, null: false
      t.column :concurrent_refresh_limit, :integer, null: false, default: 50
      t.column :refresh_interval_in_minutes, :integer, null: false, default: 1440
      t.timestamps
    end
  end
end
