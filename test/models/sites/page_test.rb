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
require "test_helper"

class Sites::PageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
