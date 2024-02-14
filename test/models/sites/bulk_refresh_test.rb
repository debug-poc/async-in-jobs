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
require "test_helper"

class Sites::BulkRefreshTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
