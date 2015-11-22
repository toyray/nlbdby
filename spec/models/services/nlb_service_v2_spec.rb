require 'rails_helper'

RSpec.describe NLBServiceV2, :type => :model do
  let(:service) { described_class.new }

  describe '#import_book' do
    subject(:book) { service.import_book(brn) }

    context 'when book has section', :vcr do
      let(:brn) { 13746636 }

      it 'builds book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Rails test prescriptions : keeping your application healthy')
        expect(book.author).to eq('Rappin, Noel')
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
        expect(book.author).to eq('Chelimsky, David')
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
        expect(book.author).to eq('Azzarello, Brian')
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
        expect(book.author).to eq('Cummings, Joe')
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
        expect(book.title).to eq('Deathwatch: Xenos hunters')
        expect(book.author).to eq('')
        expect(book.pages).to eq(409)
        expect(book.height).to eq(20)
        expect(book.call_no).to eq('DEA')
        expect(book.section).to eq('SF')
        expect(book.library_statuses).to_not be_empty
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
        expect(book.author).to eq('Peebles, Curtis')
        expect(book.pages).to eq(368)
        expect(book.height).to eq(23)
        expect(book.call_no).to eq(nil)
        expect(book.section).to eq(nil)
        expect(book.library_statuses).to be_empty
      end
    end

    context 'when book is in Singapore collection', :vcr do
      let(:brn) { 13073681 }

      it 'builds book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Building Singapore\'s longest road tunnel : the KPE story')
        expect(book.author).to eq('Cheong, Colin')
        expect(book.pages).to eq(159)
        expect(book.height).to eq(31)
        expect(book.call_no).to eq('624.193095957 CHE')
        expect(book.section).to eq(nil)
        expect(book.library_statuses).to_not be_empty
        expect(book.library_statuses[0][:singapore]).to be(true)
      end
    end

    context 'when book is lending reference', :vcr do
      let(:brn) { 9967336 }

      it 'builds book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Network intrusion detection : an analyst\'s handbook')
        expect(book.author).to eq('Northcutt, Stephen')
        expect(book.pages).to eq(430)
        expect(book.height).to eq(23)
        expect(book.call_no).to eq('005.8 NOR')
        expect(book.section).to eq(nil)
        expect(book.library_statuses).to_not be_empty
        expect(book.library_statuses[0][:reference]).to be(true)
      end
    end

    context 'when book has a whole number call no', :vcr do
      let(:brn) { 12522454 }

      it 'builds book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Freakonomics : a rogue economist explores the hidden side of everything')
        expect(book.author).to eq('Levitt, Steven D.')
        expect(book.pages).to eq(242)
        expect(book.height).to eq(24)
        expect(book.call_no).to eq('330 LEV')
        expect(book.section).to eq('BIZ')
        expect(book.library_statuses).to_not be_empty
      end
    end

    context 'when initials of author is two characters', :vcr do
      let(:brn) { 200738648 }

      it 'builds book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Backbone.js patterns and best practices : a one-stop guide to best practices and design patterns when building applications using Backbone.js')
        expect(book.author).to eq('De, Swarnendu')
        expect(book.pages).to eq(153)
        expect(book.height).to eq(24)
        expect(book.call_no).to eq('005.2762 DE')
        expect(book.section).to eq('COM')
        expect(book.library_statuses).to_not be_empty
      end
    end

    context 'when book has accompanying item of a different call no', :vcr do
      let(:brn) { 11936475 }

      it 'builds book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq('Code reading : the open source perspective')
        expect(book.author).to eq('Spinellis, Diomidis')
        expect(book.pages).to eq(495)
        expect(book.height).to eq(24)
        expect(book.call_no).to eq('005.1 SPI')
        expect(book.section).to eq('COM')
        expect(book.library_statuses).to_not be_empty
      end
    end

    context 'when initials of author is single character', :vcr do
      let(:brn) { 201073800 }

      it 'builds book' do
        expect(book).to_not be_nil
        expect(book.brn).to eq(brn)
        expect(book.title).to eq("A sniper's conflict : an elite sharpshooter's thrilling account of hunting insurgents in Afghanistan and Iraq")
        expect(book.author).to eq('B., Monty')
        expect(book.pages).to eq(198)
        expect(book.height).to eq(24)
        expect(book.call_no).to eq('356.162092 B')
        expect(book.section).to eq(nil)
        expect(book.library_statuses).to_not be_empty
      end
    end

    context 'when same library has multiple copies of book', :vcr do
      let(:brn) { 200178985 }

      it 'builds book' do
         expect(book.library_statuses.size).to eq(1)
      end
    end
  end

  describe '#update_book', :vcr do
    let(:book) { create(:book, :with_library_statuses, brn: 13746636) }
    subject(:updated_book) { service.update_book(book) }

    it { expect(updated_book.library_statuses).to_not be_empty }
  end

  describe 'extract_library_details' do
    context 'when three books exist in same library with different availablity statuses' do
      let(:library_status_a) { ['Library 1', 'Adult Lending', '123.45 ABC', '', false] }
      let(:library_status_b) { ['Library 1', 'Adult Lending', '123.45 ABC', '', true] }
      let(:library_status_c) { ['Library 1', 'Adult Lending', '123.45 ABC', '', false] }
      let(:book) { build(:book) }
      let(:info) { (1..4).to_a } # This is hacky, find a way to separate nokogiri parsing from functional logic

      before do
        allow(service).to receive(:find_library_info).and_return('')
        allow(service).to receive(:parse_library_info).and_return(library_status_a, library_status_b, library_status_c)
      end

      it 'expects to create only one library_status in book with available = true' do
        service.send(:extract_library_details, book, info)
        expect(book.library_statuses.count).to eq(1)
        expect(book.library_statuses[0][:available]).to be true
      end
    end
  end
end
