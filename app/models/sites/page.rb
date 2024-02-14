# == Schema Information
#
# Table name: sites_pages
#
#  id                :bigint           not null, primary key
#  content           :text
#  refresh_queued_at :datetime
#  refresh_status    :string           default("pending"), not null
#  refreshed_at      :datetime
#  url               :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  site_id           :bigint           not null
#
# Indexes
#
#  index_sites_pages_on_site_id  (site_id)
#
# Foreign Keys
#
#  fk_rails_...  (site_id => sites.id)
#
class Sites::Page < ApplicationRecord
  belongs_to :site

  scope :refreshable, -> { where(refresh_status: %w[success failed pending]) }
  scope :to_refresh, ->(refresh_interval_in_minutes) {
    refreshable.where("refreshed_at IS NULL OR refreshed_at < ?", Time.current - refresh_interval_in_minutes.minutes)
  }
  scope :recently_refreshed, -> { where(refresh_status: "success").where("refreshed_at > ?", Time.current - 1.hour) }
end
