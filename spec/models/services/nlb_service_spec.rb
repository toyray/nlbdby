require 'rails_helper'

RSpec.describe NLBService, :type => :model do
  describe '#import_book', :vcr => { :cassette_name => "rspec_book" } do
    let(:brn) { "13684071"}

    subject { NLBService.import_book(brn) }

    it { is_expected.to_not be_nil }
  end
end
