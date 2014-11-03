require 'rails_helper'

RSpec.describe NLBService, :type => :model do
  describe '#import_book' do
    subject(:book) { NLBService.new.import_book(brn) }

    context 'when book has section', :vcr do 
      let(:brn) { 13746636 }

      it 'builds book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Rails test prescriptions : keeping your application healthy')
        expect(book.author).to eq('Rappin, Noel,')
        expect(book.pages).to eq(348)
        expect(book.height).to eq(23)
        expect(book.call_no).to eq('005.117 RAP')
        expect(book.section).to eq('COM')
        expect(book.library_statuses).to_not be_empty
      end
    end

    context 'when book has no author', :vcr do
      let(:brn) { 13684071 }

      it 'builds book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('The RSpec book : behaviour-driven development with RSpec, Cucumber, and Friends')
        expect(book.author).to eq('')
        expect(book.pages).to eq(420)
        expect(book.height).to eq(23)
        expect(book.call_no).to eq('005.117 RSP')
        expect(book.section).to eq('COM')
        expect(book.library_statuses).to_not be_empty
      end
    end

    context 'when book has no pages', :vcr do
      let(:brn) { 14253930 }

      it 'builds book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Joker')
        expect(book.author).to eq('Azzarello, Brian.')
        expect(book.pages).to eq(0)
        expect(book.height).to eq(27)
        expect(book.call_no).to eq('741.5973 AZZ')
        expect(book.section).to eq('ART')
        expect(book.library_statuses).to_not be_empty
      end
    end

    context 'when book has no section', :vcr do
      let(:brn) { 13839470 }

      it 'builds book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Sacred tattoos of Thailand : exploring the magic, masters and mystery of sak yan')
        expect(book.author).to eq('Cummings, Joe,')
        expect(book.pages).to eq(197)
        expect(book.height).to eq(27)
        expect(book.call_no).to eq('391.650953 CUM')
        expect(book.section).to be_nil
        expect(book.library_statuses).to_not be_empty
      end
    end

    context 'when book is fiction', :vcr do
      let(:brn) { 200422270 }

      it 'builds book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Deathwatch: Xenos hunters.')
        expect(book.author).to eq('')
        expect(book.pages).to eq(409)
        expect(book.height).to eq(20)
        expect(book.call_no).to eq('DEA')
        expect(book.section).to eq('SF')
        expect(book.library_statuses).to_not be_empty
      end
    end

    context 'when book is not available from all libraries', :vcr do
      let(:brn) { 12980235 }

      it 'builds book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Implementation patterns')
        expect(book.author).to eq('Beck, Kent.')
        expect(book.pages).to eq(157)
        expect(book.height).to eq(24)
        expect(book.call_no).to eq(nil)
        expect(book.section).to eq(nil)
        expect(book.library_statuses).to be_empty
      end
    end

    context 'when book not found', :vcr do
      let(:brn) { 1 }

      it 'does not build book' do
        expect(book).to be_nil
      end
    end    

    context 'when book has no available libraries', :vcr do
      let(:brn) { 9535970 }

      it 'builds book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Dark eagles : a history of top secrets U.S. \'Black\' aircraft programs')
        expect(book.author).to eq('Peebles, Curtis.')
        expect(book.pages).to eq(368)
        expect(book.height).to eq(23)
        expect(book.call_no).to eq('623.746 PEE')
        expect(book.section).to eq(nil)
        expect(book.library_statuses).to be_empty
      end
    end
  end
end
