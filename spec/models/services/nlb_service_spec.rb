require 'rails_helper'

RSpec.describe NLBService, :type => :model do
  describe '#import_book', :vcr => { :cassette_name => "test_book" } do
    context "book with section" do 
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

    context "book with no author" do
      pending
    end

    context "book with no pages" do
      pending
    end

    context "book with no height" do
      pending
    end    

    context "book with no section" do
      pending
    end
  end
end
