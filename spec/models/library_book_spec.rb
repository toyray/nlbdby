require 'rails_helper'

RSpec.describe LibraryBook, :type => :model do
  context 'associations' do
    it { is_expected.to belong_to(:library) }
    it { is_expected.to belong_to(:book) }
  end

  context 'delegations' do
    it { is_expected.to delegate_method(:library_name).to(:library).as(:name) }
  end
end
