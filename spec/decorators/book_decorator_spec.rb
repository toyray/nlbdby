require 'rails_helper'

RSpec.describe BookDecorator, :type => :decorator do
  let(:object) { build_stubbed(:book) }
  let(:subject) { object.decorate }

  describe '#availability_badge' do
    context 'when book is available' do
      before do
        allow(object).to receive(:available?).and_return(true)
        allow(object).to receive(:read?).and_return(true)
      end

      it { expect(subject.availability_badge(nil)).to be_nil }
    end

    context 'when book is unavailable' do
      let(:read) { false }

      before do
        allow(object).to receive(:available?).and_return(false)
        allow(object).to receive(:read?).and_return(read)
      end

      context 'when book is not borrowed or archived' do
        it { expect(subject.availability_badge(nil)).to_not be_nil }
      end

      context 'when book is borrowed or archived' do
        let(:read) { true }

        it { expect(subject.availability_badge(nil)).to be_nil }
      end

      context 'when book is queued' do
        before { allow(object).to receive(:status).and_return("queued") }

        it { expect(subject.availability_badge(nil)).to be_nil }
      end
    end
  end

  describe '#reference_badge' do
    context 'when book is a reference book' do
      before { allow(object).to receive(:reference?).and_return(true) }

      it { expect(subject.reference_badge(nil)).to include('REF') }
    end

    context 'when book is not a reference book' do
      before { allow(object).to receive(:reference?).and_return(false) }

      it { expect(subject.reference_badge(nil)).to be_nil }
    end
  end

  describe '#library_count_badge' do
    context 'when book is available at 1 or less libraries' do
      before { allow(object).to receive(:library_count).and_return(1) }

      it { expect(subject.library_count_badge).to include('label-danger') }
    end

    context 'when book is available at 2 to 4 libraries' do
      before { allow(object).to receive(:library_count).and_return(3) }

      it { expect(subject.library_count_badge).to include('label-warning') }
    end

    context 'when book is available at 5 or more libraries' do
      context 'when available at less than 10 libraries'  do
        before { allow(object).to receive(:library_count).and_return(5) }

        it { expect(subject.library_count_badge).to include('label-success').and include('5') }
      end

      context 'when available at 10 or more libraries'  do
        before { allow(object).to receive(:library_count).and_return(10) }

        it { expect(subject.library_count_badge).to include('label-success').and include('9+') }
      end
    end
  end
end
