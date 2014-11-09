require 'rails_helper'

RSpec.describe BookUserMeta, :type => :model do
  context 'associations' do
    it { expect(subject).to belong_to(:book) }
  end
end
