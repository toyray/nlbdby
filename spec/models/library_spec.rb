require 'rails_helper'

RSpec.describe Library, :type => :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to_not allow_value(nil).for(:regional) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe '.available?' do
    subject { Library.available?(library) }

    context 'when library is one of the Lee Kong Chian Reference Libraries' do
      let(:library) { 'Lee Kong Chian Reference Library Lvl 7'}

      it { is_expected.to be false }
    end

    context 'when library is Repository Used Book Collection' do
      let(:library) { 'Repository Used Book Collection'}

      it { is_expected.to be false }
    end

    context 'when other libraries' do
      let(:library) { 'Central Public Library'}

      it { is_expected.to be true }
    end
  end

  describe '.regional?' do
    subject { Library.regional?(library) }

    context 'when library has Regional in name' do
      let(:library) { 'Woodlands Regional Library' }

      it { is_expected.to be true }
    end

    context 'when library does not have Regional in name' do
      let(:library) { 'library@orchard' }

      it { is_expected.to be false }
    end
  end
end
