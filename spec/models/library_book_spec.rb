require 'rails_helper'

RSpec.describe LibraryBook, :type => :model do
  context 'associations' do
    it { expect(subject).to belong_to(:library) }
    it { expect(subject).to belong_to(:book) }
  end
end
