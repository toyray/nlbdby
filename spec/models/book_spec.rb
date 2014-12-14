require 'rails_helper'

RSpec.describe Book, :type => :model do
  context 'associations' do
    it { is_expected.to have_many(:library_books) }
    it { is_expected.to have_one(:meta).class_name('BookUserMeta') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:brn) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:pages) }
    it { is_expected.to validate_presence_of(:height) }
    it { is_expected.to validate_presence_of(:call_no) }

    it { is_expected.to_not allow_value(nil).for(:author) }
    it { is_expected.to ensure_length_of(:author).is_at_least(0) }
    it { is_expected.to validate_uniqueness_of(:brn) }
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

  context 'after_save callbacks' do
    describe '#create_new_libraries' do
      let(:book) { build(:book, :with_library_statuses, library_status_count: 3) }

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
          expect(Library.exists?(name: s[:library])).to be(true)
        end
      end
    end

    describe '#update_library_books' do
      let(:book) { build(:book, :with_library_statuses, library_status_count: 3) }

      it 'creates library books' do
        expect {
          book.save
        }.to change(LibraryBook, :count).by(3)
      end

      context 'when creating library books' do
        let(:book) { build(:book, :with_library_statuses) }
        let(:status) { book.library_statuses.first}
        
        it 'creates library books with the correct library name and availability' do
          book.save
          expect(LibraryBook.last.library_name).to eq(status[:library])
          expect(LibraryBook.last.available).to eq(status[:available])
          expect(LibraryBook.last.singapore).to eq(status[:singapore])
          expect(LibraryBook.last.reference).to eq(status[:reference])
        end
      end
    end
  end

  describe '.import' do
    let(:brn) { 1 }

    before { allow_any_instance_of(NLBService).to receive(:import_book).and_return(book) }
    
    context 'when book is valid' do
      let(:book) { build(:book, :with_library_statuses, brn: 1) }

      it { expect{Book.import(brn)}.to change(Book, :count).by(1) }
      it { expect(Book.import(brn)).to eq [book, nil] }
    end

    context 'when book already exists with brn' do
      let!(:existing_book) { create(:book) }
      let(:book) { nil }
      let(:brn) { existing_book.brn }

      it { expect{Book.import(brn)}.to_not change(Book, :count) }
      it { expect(Book.import(brn)).to eq [nil, 'A book with this BRN has already been imported.'] }
    end

    context 'when brn is invalid' do
      let(:book) { nil }

      it { expect{Book.import(brn)}.to_not change(Book, :count) }
      it { expect(Book.import(brn)).to eq [nil, 'No book with this BRN found.'] }
    end

    context 'when book has no available libraries' do
      let(:book) { build(:book, :without_library_statuses) }

      it { expect{Book.import(brn)}.to_not change(Book, :count) }
      it { expect(Book.import(brn)).to eq [nil, 'Book is not available for borrowing in any library.'] }
    end
  end

  describe '.import_from_yaml' do
    context 'when user metadata does not exist' do
      let(:books_yaml) { 
        <<-BOOKS_YAML.strip_heredoc
        ---
        1:
        2:
        BOOKS_YAML
      }
      let(:book1) { create(:book, :with_library_statuses, brn: 1) }
      let(:book2) { create(:book, :with_library_statuses, brn: 2) }

      it 'creates Book and BookUserMeta objects with default values' do
        expect(Book).to receive(:import).with(1).and_return([book1, nil])
        expect(Book).to receive(:import).with(2).and_return([book2, nil])
        errors = Book.import_from_yaml(books_yaml)
        expect(errors).to be_empty
      end
    end

    context 'when user metadata exists' do
      let(:books_yaml) { 
        <<-BOOKS_YAML.strip_heredoc
        ---
        1:
          rating: 4
          borrowed: true
        BOOKS_YAML
      }

      let(:book) { create(:book, :with_library_statuses, brn: 1) }
      let(:meta) { book.meta}

      it 'updates BookUserMeta with values from YAML' do
        expect(Book).to receive(:import).with(1).and_return([book, nil])
        errors = Book.import_from_yaml(books_yaml)
        expect(meta.rating).to eq 4
        expect(meta.borrowed).to be true
        expect(errors).to be_empty
      end
    end

    context 'when yaml is malformed' do
      let(:books_yaml) { 
        <<-BOOKS_YAML.strip_heredoc
        ---
        1
          rating: 4
          borrowed: true
        BOOKS_YAML
      }

      it { expect{Book.import_from_yaml(books_yaml)}.to_not change(Book, :count) }
    end

    context 'when errors are encountered during importing' do
      let(:books_yaml) { 
        <<-BOOKS_YAML.strip_heredoc
        ---
        1:
        2:
        BOOKS_YAML
      }
      let(:book) { create(:book, :with_library_statuses, brn: 1) }

      it 'creates Book and BookUserMeta objects with default values' do
        expect(Book).to receive(:import).with(1).and_return([book, nil])
        expect(Book).to receive(:import).with(2).and_return([nil, 'error message'])
        errors = Book.import_from_yaml(books_yaml)
        expect(errors.keys).to match_array([2])
        expect(errors[2]).to eq('error message')
      end      
    end
  end

  describe '.export_to_yaml' do
    let(:books_yaml) { 
      <<-BOOKS_YAML.strip_heredoc
      ---
      1:
        rating: 2
        borrowed: true
      2:
        rating: 4
        borrowed: false
      BOOKS_YAML
    }    
    let!(:book_a) { create(:book, :with_library_statuses, brn: 2) }
    let!(:book_b) { create(:book, :with_library_statuses, brn: 1) }

    before do
      book_a.meta.rating = 4
      book_a.meta.save
      book_b.meta.borrowed = true
      book_b.meta.save
    end

    it { expect(Book.export_to_yaml).to eq(books_yaml) }
  end

  describe '#status' do
    subject { build(:book, :with_library_statuses) }

    it 'should be completed initially' do
      expect(subject.completed?).to be true
    end

    context 'when status is completed' do
      it 'should change to queued on queue_update' do
        expect(subject).to receive(:update_availability).and_return(true)
        subject.queue_update
        expect(subject.queued?).to be true
      end
    end

    context 'when status is queued' do
      subject { build(:book, :with_library_statuses, status: :queued) }

      it 'should changed to completed on finish_update' do
        expect(subject).to receive(:update_timestamps)
        subject.finish_update
        expect(subject.completed?).to be true
      end
    end
  end
end
