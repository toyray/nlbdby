require 'rails_helper'

RSpec.describe LibraryBook, :type => :model do
  context 'associations' do
    it { should belong_to(:library) }
    it { should belong_to(:book) }
  end
end
