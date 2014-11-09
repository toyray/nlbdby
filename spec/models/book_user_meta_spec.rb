require 'rails_helper'

RSpec.describe BookUserMeta, :type => :model do
  context 'associations' do
    it { is_expected.to belong_to(:book) }
  end
end
