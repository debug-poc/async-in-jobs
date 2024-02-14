# == Schema Information
#
# Table name: sites_bulk_refreshes
#
#  id         :bigint           not null, primary key
#  page_data  :jsonb            not null
#  status     :string           default("pending"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  site_id    :bigint           not null
#
# Indexes
#
#  index_sites_bulk_refreshes_on_site_id  (site_id)
#
# Foreign Keys
#
#  fk_rails_...  (site_id => sites.id)
#
require "async/http/internet"
require "async/barrier"
class Sites::BulkRefresh < ApplicationRecord
  PAGES_PER_BULK_REFRESH_JOB = 20

  # Using https://github.com/kaspth/active_job-performs for a more concise way to define the job
  extend ActiveJob::Performs
  performs :execute

  scope :pending, -> { where(status: "pending") }
  scope :processing, -> { where(status: "processing") }
  scope :pending_or_processing, -> { where(status: %w[pending processing]) }

  def execute
    puts "Executing bulk refresh for site #{site_id}"
    puts "ActiveRecord::Base.connection_pool.stat: #{ActiveRecord::Base.connection_pool.stat}"
    update!(status: "processing")
    Sync do
      barrier = Async::Barrier.new
      internet = Async::HTTP::Internet.new
      results = []
      mutex = Mutex.new

      # No ActiveRecord calls to be made inside the block. We want to use only one AR connection per job
      page_data.each do |id, url|
        barrier.async do
          result = {id: id}
          begin
            # Simulate a network delay
            sleep(rand(1..5))
            puts "ActiveRecord::Base.connection_pool.stat in async job for page #{id}: #{ActiveRecord::Base.connection_pool.stat}"
            response = internet.get url
            result.merge!(content: response.read, status: "success")
          rescue => e
            result.merge!(status: "failed")
            Rails.logger.error "Failed to refresh page #{id} with error: #{e.message}"
            # Report error
          end
          mutex.synchronize { results.push(result) }
        end
      end

      barrier.wait

      results.each do |result|
        if result[:status] == "success"
          Sites::Page.update(
            result[:id],
            content: result[:content], refresh_status: "success", refreshed_at: Time.current, refresh_queued_at: nil
          )
        else
          Sites::Page.update(result[:id], refresh_status: "failed")
        end
      end
    ensure
      internet&.close
    end
    update!(status: "completed")
    # No need to keep this around
    # destroy!
  end
end
