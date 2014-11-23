require 'rails_helper'

RSpec.describe HomeController, :type => :controller do
  describe "GET index" do
    it 'redirects to books#index' do
      get :index
      expect(response).to redirect_to :books
    end
  end
end
