require 'rails_helper'

RSpec.describe BookDecorator, :type => :decorator do
  let(:object) { build_stubbed(:book) }
  let(:subject) { object.decorate }

  describe '#availability_status' do
    context 'when book is available' do
      before { allow(object).to receive(:available?).and_return(true) }

      it { expect(subject.availability_status(nil)).to eq('YES') }
    end

    context 'when book is unavailable' do
      before { allow(object).to receive(:available?).and_return(false) }

      it { expect(subject.availability_status(nil)).to eq('NO') }
    end
  end
end
