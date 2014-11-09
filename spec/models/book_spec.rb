require 'rails_helper'

RSpec.describe Book, :type => :model do  
  context 'validations' do
    it { should validate_presence_of(:brn) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author) }
    it { should validate_presence_of(:pages) }
    it { should validate_presence_of(:height) }
    it { should validate_presence_of(:call_no) }
  end

  describe '#unavailable?' do
    subject { book.unavailable? }

    context 'when library statuses is empty' do
      let(:book) { build(:book, :without_library_statuses) }

      it { is_expected.to be true }
    end

    context 'when library statuses is not empty' do
      let(:book) { build(:book, :with_library_statuses) }

      it { is_expected.to be false }      
    end
  end

  context 'after_create callbacks' do
    describe '#create_book_meta' do
      let(:book) { build(:book) }

      it 'creates BookUserMeta object' do
        expect {
          book.save
        }.to change(BookUserMeta, :count).by(1)
      end

      it 'assigns BookUserMeta object to this book' do
        book.save
        expect(BookUserMeta.last.book_id).to eq(book.id)
      end
    end
  end
end
