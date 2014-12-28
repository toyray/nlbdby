require 'rails_helper'

RSpec.describe ApplicationHelper, :type => :helper do
  describe '#attr_row' do
    let(:book) { build(:book, pages: 233) }

    it { expect(helper.attr_row(book, :pages)).to eq('<tr><td class="col-xs-4">Pages</td><td class="col-xs-8">233</td></tr>') }
  end

  describe '#bootstrap_alert_class' do
    it { expect(helper.bootstrap_alert_class(:alert)).to eq('alert-danger') }
    it { expect(helper.bootstrap_alert_class(:notice)).to eq('alert-success') }
    it { expect(helper.bootstrap_alert_class('alert')).to eq('alert-danger') }
    it { expect(helper.bootstrap_alert_class('notice')).to eq('alert-success') }
    it { expect(helper.bootstrap_alert_class(nil)).to eq('alert-info') }
  end
end
