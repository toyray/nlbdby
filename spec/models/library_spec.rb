require 'rails_helper'

RSpec.describe Library, :type => :model do
  context 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe '.available?' do
    subject { Library.available?(library) }

    context 'when Lee Kong Chian Reference Libraries' do
      let(:library) { 'Lee Kong Chian Reference Library Lvl 7'}

      it { is_expected.to be false }
    end

    context 'when Repository Used Book Collection' do
      let(:library) { 'Repository Used Book Collection'}

      it { is_expected.to be false }
    end

    context 'when other libraries' do
      let(:library) { 'Central Public Library'}

      it { is_expected.to be true }
    end
  end
end
