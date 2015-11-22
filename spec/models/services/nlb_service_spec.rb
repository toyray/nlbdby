require 'rails_helper'

RSpec.describe NLBService, :type => :model do
  let(:service) { described_class.new }

  describe '#parse_height' do
    it { expect(service.send(:parse_height, '409 pages ;20 cm.')).to eq(20) }
    it { expect(service.send(:parse_height, '159 p. :ill. (chiefly col.), col. maps ; 27 x 31 cm.')).to eq(31) }
    it { expect(service.send(:parse_height, 'xxviii, 495 p. ;24 cm. +1 CD-ROM (4 3/4 in.)')).to eq(24) }
    it { expect(service.send(:parse_height, 'xx, 198 pages :color illustrations ;24 cm')).to eq(24) }
  end

  describe '#parse_pages' do
    it { expect(service.send(:parse_pages, '409 pages ;20 cm.')).to eq(409) }
    it { expect(service.send(:parse_pages, '159 p. :ill. (chiefly col.), col. maps ; 27 x 31 cm.')).to eq(159) }
    it { expect(service.send(:parse_pages, 'xxviii, 495 p. ;24 cm. +1 CD-ROM (4 3/4 in.)')).to eq(495) }
    it { expect(service.send(:parse_pages, 'xx, 198 pages :color illustrations ;24 cm')).to eq(198) }
  end

  describe 'lendable?' do
    it { expect(service.send(:lendable?, 'Young Adult Lending')).to be true }
    it { expect(service.send(:lendable?, 'Adult Lending')).to be true }
    it { expect(service.send(:lendable?, 'Adult Lending Singapore Collection')).to be true }
    it { expect(service.send(:lendable?, 'Lending Reference')).to be true }
    it { expect(service.send(:lendable?, 'Accompanying Item')).to be false }
    it { expect(service.send(:lendable?, 'Reference Southeast Asia')).to be false }
    it { expect(service.send(:lendable?, 'Reference Singapore')).to be false }
    it { expect(service.send(:lendable?, 'Reference')).to be  false }
  end
end
