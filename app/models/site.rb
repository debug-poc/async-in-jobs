# == Schema Information
#
# Table name: sites
#
#  id                          :bigint           not null, primary key
#  concurrent_refresh_limit    :integer          default(50), not null
#  name                        :string           not null
#  refresh_interval_in_minutes :integer          default(1440), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
class Site < ApplicationRecord
  has_many :pages, class_name: "Sites::Page"
  has_many :bulk_refreshes, class_name: "Sites::BulkRefresh"

  def enqueue_refresh
    pending_or_processing_bulk_refresh_count = bulk_refreshes.pending_or_processing.size
    bulk_refresh_limit = max_concurrent_bulk_refreshes - pending_or_processing_bulk_refresh_count
    return if bulk_refresh_limit <= 0

    max_pages_count = bulk_refresh_limit * Sites::BulkRefresh::PAGES_PER_BULK_REFRESH_JOB

    pages = pages_to_refresh(max_pages_count)

    if pages.size > 0
      pages.update_all(refresh_status: "queued", refresh_queued_at: Time.current)
      pages_data = pages.pluck(:id, :url)

      pages_data.each_slice(Sites::BulkRefresh::PAGES_PER_BULK_REFRESH_JOB) do |page_data|
        bulk_refresh = bulk_refreshes.create!(page_data: page_data, status: "pending")
        bulk_refresh.execute_later
      end
    end
    {enqueued: pages.size}
  end

  def pages_to_refresh(max_pages_count)
    pages.to_refresh(refresh_interval_in_minutes).limit(max_pages_count)
  end

  def max_concurrent_bulk_refreshes
    if concurrent_refresh_limit < Sites::BulkRefresh::PAGES_PER_BULK_REFRESH_JOB
      concurrent_refresh_limit
    else
      concurrent_refresh_limit / Sites::BulkRefresh::PAGES_PER_BULK_REFRESH_JOB
    end
  end
end
