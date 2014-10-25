require 'rails_helper'

RSpec.describe Book, :type => :model do  
  context 'validations' do
    it { should validate_presence_of(:brn) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author) }
    it { should validate_presence_of(:pages) }
    it { should validate_presence_of(:height) }
    it { should validate_presence_of(:call_no) }
  end
end
