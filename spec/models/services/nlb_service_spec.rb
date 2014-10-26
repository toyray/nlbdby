require 'rails_helper'

RSpec.describe NLBService, :type => :model do
  describe '#import_book', :vcr => { :cassette_name => 'test_book' } do
    context 'book with section' do 
      let(:brn) { 13746636 }

      subject(:book) { NLBService.new.import_book(brn) }

      it { expect(book).to_not be_nil }
      it { expect(book.brn).to eq(brn) }
      it { expect(book.title).to eq('Rails test prescriptions : keeping your application healthy') }
      it { expect(book.author).to eq('Rappin, Noel,') }
      it { expect(book.pages).to eq(348) }
      it { expect(book.height).to eq(23) }
      it { expect(book.call_no).to eq('005.117 RAP') }
      it { expect(book.section).to eq('COM') }
    end

    context 'book with no author' do
      let(:brn) { 13684071 }
      pending
    end

    context 'book with no pages' do
      let(:brn) { 14253930 }
      pending
    end

    context 'book with no section' do
      let(:brn) { 13839470 }
      pending
    end

    context 'fiction book' do
      let(:brn) { 200422270 }
      pending
    end

    context 'book with no libraries' do
      let(:brn) { 12980235 }
      pending
    end

    context 'book with no valid libraries to borrow from' do
      let(:brn) { 9535970 }
      pending
    end

    context 'book not found' do
      let(:brn) { 1 }
      pending
    end
  end
end
