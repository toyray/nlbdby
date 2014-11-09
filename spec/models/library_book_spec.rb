require 'rails_helper'

RSpec.describe LibraryBook, :type => :model do
  context 'associations' do
    it { is_expected.to belong_to(:library) }
    it { is_expected.to belong_to(:book) }
  end
end
