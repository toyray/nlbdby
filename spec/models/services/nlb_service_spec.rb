require 'rails_helper'

RSpec.describe NLBService, :type => :model do
  describe '#import_book' do
    subject(:book) { NLBService.new.import_book(brn) }

    context 'book with section', :vcr do 
      let(:brn) { 13746636 }

      it 'creates book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Rails test prescriptions : keeping your application healthy')
        expect(book.author).to eq('Rappin, Noel,')
        expect(book.pages).to eq(348)
        expect(book.height).to eq(23)
        expect(book.call_no).to eq('005.117 RAP')
        expect(book.section).to eq('COM')
      end
    end

    context 'book with no author', :vcr do
      let(:brn) { 13684071 }

      it 'creates book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('The RSpec book : behaviour-driven development with RSpec, Cucumber, and Friends')
        expect(book.author).to eq('')
        expect(book.pages).to eq(420)
        expect(book.height).to eq(23)
        expect(book.call_no).to eq('005.117 RSP')
        expect(book.section).to eq('COM')
      end
    end

    context 'book with no pages', :vcr do
      let(:brn) { 14253930 }

      it 'creates book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Joker')
        expect(book.author).to eq('Azzarello, Brian.')
        expect(book.pages).to eq(0)
        expect(book.height).to eq(27)
        expect(book.call_no).to eq('741.5973 AZZ')
        expect(book.section).to eq('ART')
      end
    end

    context 'book with no section', :vcr do
      let(:brn) { 13839470 }

      it 'creates book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Sacred tattoos of Thailand : exploring the magic, masters and mystery of sak yan')
        expect(book.author).to eq('Cummings, Joe,')
        expect(book.pages).to eq(197)
        expect(book.height).to eq(27)
        expect(book.call_no).to eq('391.650953 CUM')
        expect(book.section).to be_nil
      end
    end

    context 'fiction book', :vcr do
      let(:brn) { 200422270 }

      it 'creates book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Deathwatch: Xenos hunters.')
        expect(book.author).to eq('')
        expect(book.pages).to eq(409)
        expect(book.height).to eq(20)
        expect(book.call_no).to eq('DEA')
        expect(book.section).to eq('SF')
      end
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
