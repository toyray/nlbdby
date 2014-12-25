require 'rails_helper'

RSpec.describe ImportLogger, :type => :model do
  describe '.error' do
    let(:brn) { 1 } 
    let(:error) { :unavailable }
    let(:logger) { double('logger').as_null_object }

    before { allow(ImportLogger).to receive(:logger).and_return(logger) }
    
    it 'writes to log' do
      expect(logger).to receive(:error).with('1: Book is not available for borrowing in any library.')
      ImportLogger.error(brn, error)
    end
  end
end
