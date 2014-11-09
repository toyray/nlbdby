require 'rails_helper'

RSpec.describe BooksController, :type => :controller do
  describe "GET new" do
    it 'renders template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST create" do
    let(:params) { { brn: 1 } }

    before { allow_any_instance_of(NLBService).to receive(:import_book).and_return(book) }

    def do_request
      post :create, book: params
    end

    context 'when params are valid' do
      let(:book) { build(:book, :with_library_statuses) }

      it 'saves book object' do
        expect {
          do_request
        }.to change(Book, :count).by(1)
      end

      it 'redirects to show' do
        do_request
        expect(response).to redirect_to(action: :show, id: assigns(:book).id)
      end
    end

    context 'when params are invalid' do
      before { do_request }

      context 'when brn is invalid' do
        let(:book) { nil }

        it 'renders view with error' do
          expect(response).to render_template(:new)
          expect(flash[:error]).to_not be_nil
        end
      end

      context 'when book has no available libraries' do
        let(:book) { build(:book, :without_library_statuses) }

        it 'renders view with error' do
          expect(response).to render_template(:new)
          expect(flash[:error]).to_not be_nil
        end
      end
    end 
  end
end
