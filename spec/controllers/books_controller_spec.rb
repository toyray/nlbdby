require 'rails_helper'

RSpec.describe BooksController, :type => :controller do
  describe 'GET index' do
    let!(:books) { create_list(:book, 2) }

    it 'renders template' do
      get :index
      expect(assigns(:books)).to match_array(books)
      expect(response).to render_template(:index)
    end
  end

  describe 'GET new' do
    it 'renders template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    let(:params) { { brn: 1 } }

    before { allow_any_instance_of(NLBService).to receive(:import_book).and_return(book) }

    def do_request
      post :create, book: params
    end

    context 'when params are valid' do
      let(:book) { build(:book, :with_library_statuses) }

      it 'saves book object' do
        expect{do_request}.to change(Book, :count).by(1)
      end

      it 'redirects to show' do
        do_request
        expect(response).to redirect_to(action: :show, id: assigns(:book).id)
      end
    end

    context 'when params are invalid' do
      let(:book) { nil }

      before { do_request }

      it 'renders view with error' do
        expect(response).to render_template(:new)
        expect(flash[:error]).to_not be_nil
      end
    end 
  end

  describe 'POST import' do
    let(:file) { fixture_file_upload('files/import.yaml', 'application/x-yaml') }

    it 'redirects to index' do
      expect(Book).to receive(:import_from_yaml).and_return({})
      post :import, book: { file: file }
      expect(response).to redirect_to(action: :index)
    end
  end
end
