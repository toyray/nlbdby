require 'rails_helper'

RSpec.describe Book, :type => :model do
  context 'associations' do
    it { is_expected.to have_many(:library_books).dependent(:destroy) }
    it { is_expected.to have_many(:libraries).through(:library_books) }
    it { is_expected.to have_one(:meta).class_name('BookUserMeta').dependent(:destroy) }
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
          expect(Library.exists?(name: s[:library], regional: false)).to be(true)
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
      it { expect(Book.import(brn)).to eq [nil, :already_imported] }
    end

    context 'when brn is invalid' do
      let(:book) { nil }

      it { expect{Book.import(brn)}.to_not change(Book, :count) }
      it { expect(Book.import(brn)).to eq [nil, :invalid_brn] }
    end

    context 'when book has no available libraries' do
      let(:book) { build(:book, :without_library_statuses) }

      it { expect{Book.import(brn)}.to_not change(Book, :count) }
      it { expect(Book.import(brn)).to eq [nil, :unavailable] }
    end

    context 'when book fails validation' do
      let(:book) { build(:book, :with_library_statuses, call_no: nil) }

      it { expect{Book.import(brn)}.to_not change(Book, :count) }
      it { expect(Book.import(brn)).to eq [nil, :save_failed] }
    end    
  end

  describe '.import_from_yaml' do
    before { allow(Book).to receive(:delay).and_return(Book) }

    context 'when user metadata does not exist' do
      let(:books_yaml) { 
        <<-BOOKS_YAML.strip_heredoc
        ---
        1:
        2:
        BOOKS_YAML
      }

      it 'imports books of specified BRNs' do
        expect(Book).to receive(:import_and_save).with(1, nil)
        expect(Book).to receive(:import_and_save).with(2, nil)
        Book.import_from_yaml(books_yaml)
      end
    end

    context 'when user metadata exists' do
      let(:books_yaml) { 
        <<-BOOKS_YAML.strip_heredoc
        ---
        1:
          rating: 4
          status: borrowed
          starred: true
        BOOKS_YAML
      }

      let(:meta_hash) { { 'rating' => 4, 'status' => 'borrowed', 'starred' => true } }

      it 'imports books of specified BRNs and meta' do
        expect(Book).to receive(:import_and_save).with(1, meta_hash)
        Book.import_from_yaml(books_yaml)
      end
    end

    context 'when yaml is malformed' do
      let(:books_yaml) { 
        <<-BOOKS_YAML.strip_heredoc
        ---
        1
          rating: 4
        BOOKS_YAML
      }

      it 'does not import any books' do
        expect(Book).to_not receive(:import_and_save)
        Book.import_from_yaml(books_yaml)
      end
    end

    context 'when book already exists' do
      let(:books_yaml) { 
        <<-BOOKS_YAML.strip_heredoc
        ---
        1:
        2:
        BOOKS_YAML
      }
      let!(:book) { create(:book, :with_library_statuses, brn: 1) }

      it 'imports books of specified BRNs that do not already exist' do
        expect(Book).to_not receive(:import_and_save).with(1, nil)
        expect(Book).to receive(:import_and_save).with(2, nil)
        Book.import_from_yaml(books_yaml)
      end
    end    
  end

  describe '.export_to_yaml' do
    let(:books_yaml) { 
      <<-BOOKS_YAML.strip_heredoc
      ---
      2:
        rating: 4
        status: new
        starred: true
      1:
        rating: 3
        status: borrowed
        starred: false
      BOOKS_YAML
    }    
    let!(:book_a) { create(:book, :with_library_statuses, brn: 2) }
    let!(:book_b) { create(:book, :with_library_statuses, brn: 1) }

    before do
      book_a.meta.rating = 4
      book_a.meta.starred = true
      book_a.meta.save
      book_b.meta.borrow
      book_b.meta.rating = 3
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
        expect(subject).to receive(:update_availability_async).and_return(true)
        subject.queue_update
        expect(subject.queued?).to be true
      end
    end

    context 'when status is queued' do
      subject { build(:book, :with_library_statuses, status: 'queued') }

      it 'should changed to completed on finish_update' do
        expect(subject).to receive(:update_timestamps)
        subject.finish_update
        expect(subject.completed?).to be true
      end
    end
  end

  describe '#update_timestamps' do
    subject { build_stubbed(:book, :with_library_statuses) }

    it { expect{ subject.update_timestamps }.to change{ subject.last_updated_at } }
  end

  describe '#update_availability' do
    subject { create(:book, :with_library_statuses, status: 'queued') }

    before { allow_any_instance_of(NLBService).to receive(:update_book) }

    it { expect { subject.update_availability }.to change{ subject.status }.from('queued').to('completed') }
  end

  describe '.import_and_save' do
    context 'when no metadata' do
      let(:brn) { 1 }
      let(:meta) { nil }
      let(:book) { create(:book, :with_library_statuses, brn: 1) }

      it 'creates Book and BookUserMeta objects with default values' do
        expect(Book).to receive(:import).with(brn).and_return([book, nil])
        expect(ImportLogger).to_not receive(:error)
        Book.import_and_save(brn, meta)
      end
    end

    context 'when user metadata exists' do
      let(:brn) { 1 }
      let(:meta) { { rating: 4, status: 'borrowed' } }
      let(:book) { create(:book, :with_library_statuses, brn: 1) }
      let(:book_meta) { book.meta }

      it 'updates BookUserMeta with values from YAML' do
        expect(Book).to receive(:import).with(brn).and_return([book, nil])
        expect(ImportLogger).to_not receive(:error)
        Book.import_and_save(brn, meta)
        expect(book_meta.rating).to eq 4
        expect(book_meta.borrowed?).to be true
      end
    end

    context 'when errors are encountered during importing' do
      let(:brn) { 1 }
      let(:error) { :unavailable }

      it 'log errors' do
        expect(Book).to receive(:import).with(brn).and_return([nil, error])
        expect(ImportLogger).to receive(:error).with(brn, error)
        Book.import_and_save(brn, nil)
      end
    end
  end

  describe '#available?' do
    let(:book) { create(:book, :with_library_statuses, library_status_count: 2) }

    context 'when library is specified' do
      let(:subject) { book.available?(library.id) }

      context 'when book is unavailable in library' do
        let(:library) { create(:library) }

        it { is_expected.to be false }
      end

      context 'when book is available in library' do
        let(:library) { book.libraries.first }

        it { is_expected.to be true }
      end
    end

    context 'when library is not specified' do
      let(:subject) { book.available? }

      context 'when book is unavailable in library' do
        before { allow(book).to receive(:available_count).and_return(0) }
        
        it { is_expected.to be false }
      end

      context 'when book is available in library' do
        before { allow(book).to receive(:available_count).and_return(2) }

        it { is_expected.to be true }
      end
    end
  end
end
