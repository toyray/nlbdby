require 'rails_helper'

RSpec.describe Book, :type => :model do  
  context 'validations' do
    it { expect(subject).to validate_presence_of(:brn) }
    it { expect(subject).to validate_presence_of(:title) }
    it { expect(subject).to validate_presence_of(:author) }
    it { expect(subject).to validate_presence_of(:pages) }
    it { expect(subject).to validate_presence_of(:height) }
    it { expect(subject).to validate_presence_of(:call_no) }

    it { expect(subject).to validate_uniqueness_of(:brn) }
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

    describe '#create_new_libraries' do
      let(:book) { build(:book, :with_library_statuses, library_count: 3) }

      context "when libraries exist with the same name" do
        let(:library_name) { book.library_statuses[1][:library] }
        let!(:library) { create(:library, name: library_name)}

        it 'only creates new libraries' do
          expect {
            book.save
          }.to change(Library, :count).by(2)
        end
      end

      it 'creates libraries with the correct names' do
        book.save
        expect(Library.count).to eq(3)
        book.library_statuses.each do |s|
          expect(Library.exists?(name: s[:library])).to be true
        end
      end
    end
  end
end
