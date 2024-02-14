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
require "test_helper"

class SiteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
