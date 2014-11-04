require 'rails_helper'

RSpec.describe BooksController, :type => :controller do
  describe "GET new" do
    it 'renders template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST create" do
    context 'when params are valid' do
      pending
    end

    context 'when params are invalid' do
      context 'when brn is invalid' do
        let(:params) { { brn: 1 } } 

        it 'renders view with error' do
          allow_any_instance_of(NLBService).to receive(:import_book).and_return(nil)

          post :create, book: params
          expect(response).to render_template(:new)
          expect(flash[:error]).to_not be_nil
        end
      end

      context 'when book has no available libraries' do
        let(:params) { { brn: 1 } }
        let(:book)   { create(:book, :without_library_statuses) }

        it 'renders view with error' do
          allow_any_instance_of(NLBService).to receive(:import_book).and_return(book)

          post :create, book: params
          expect(response).to render_template(:new)
          expect(flash[:error]).to_not be_nil
        end
      end
    end 
  end
end
