require 'rails_helper'

RSpec.describe BookUserMeta, :type => :model do
  context 'associations' do
    it { is_expected.to belong_to(:book) }
  end

  describe '#status' do
    subject { build(:book_user_meta, starred: true) }

    it 'should be new initially' do
      expect(subject.new?).to be true
    end

    context 'when status is new' do
      it 'should change to browsed on browse' do
        subject.browse
        expect(subject.browsed?).to be true
      end

      it 'should change to borrowed on borrow' do
        subject.borrow
        expect(subject.rating).to eq(0)
        expect(subject.starred?).to be false
        expect(subject.borrowed?).to be true
      end
    end

    context 'when status is browsed' do
      subject { build(:book_user_meta, status: 'browsed', starred: true) }

      it 'should change to borrowed on borrow' do
        subject.borrow
        expect(subject.rating).to eq(0)
        expect(subject.starred?).to be false
        expect(subject.borrowed?).to be true
      end

      it 'should change to new on revert_to_new' do
        subject.revert
        expect(subject.new?).to be true
      end      
    end

    context 'when status is borrowed' do
      subject { build(:book_user_meta, status: 'borrowed') }

      it 'should change to new on revert_to_new' do
        subject.revert
        expect(subject.new?).to be true
      end

      it 'should change to archived on archive' do
        subject.archive
        expect(subject.archived?).to be true
      end       
    end  
  end
end
