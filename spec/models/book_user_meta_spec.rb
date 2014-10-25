require 'rails_helper'

RSpec.describe BookUserMeta, :type => :model do
  context 'associations' do
    it { should belong_to(:book) }
  end
end
