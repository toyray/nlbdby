require 'rails_helper'

RSpec.describe BooksController, :type => :controller do
  describe 'GET index' do
    let(:params) { nil }

    before { get :index, params }    
    
    context 'when no search params are specified' do
      let!(:books) { create_list(:book, 2) }
      
      it 'renders template' do
        expect(assigns(:q)).to be_present
        expect(assigns(:books)).to match_array(books)
        expect(response).to render_template(:index)
      end
    end

    context 'when meta_status_eq is blank' do
      let!(:new_books) { create_list(:book, 2) }
      let!(:borrowed_books) { create_list(:book, 2, :borrowed) }

      it 'displays only books that are not borrowed' do
        expect(assigns(:q)).to be_present
        expect(assigns(:books)).to match_array(new_books)
        expect(response).to render_template(:index)
      end
    end

    context 'when meta_status_eq is not blank' do
      let!(:new_books) { create_list(:book, 2) }
      let!(:borrowed_books) { create_list(:book, 2, :borrowed) }
      let(:params) { { q: { meta_status_eq: 'borrowed' } } }

      it 'displays only books of that status' do
        expect(assigns(:q)).to be_present
        expect(assigns(:books)).to match_array(borrowed_books)
        expect(response).to render_template(:index)
      end
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

  describe 'POST export' do
    before { Timecop.freeze(Time.local(2014, 12, 31, 12, 0, 0)) }
    after { Timecop.return }

    it 'redirects to YAML file' do
      expect(controller).to receive(:send_data).with(anything, hash_including(filename: 'books20141231.yaml', type: 'application/yaml')) { controller.render nothing: true }
      post :export
    end
  end

  describe 'POST queue_update' do
    let(:book) { create(:book, :with_library_statuses) }

    before do
      expect_any_instance_of(Book).to receive(:update_availability_async)
      post :queue_update, id: book.id
    end
    
    it { expect(assigns(:book).queued?).to be true }
    it { is_expected.to redirect_to(action: :index) }
  end

  describe 'GET show' do
    let(:book) { create(:book, :with_library_statuses) }

    before { get :show, id: book.id }
    
    it { is_expected.to render_template(:show) }
  end

  describe 'POST borrow' do
    let(:book) { create(:book, :with_library_statuses) }

    before { post :borrow, id: book.id }
    
    it { expect(assigns(:book).meta.borrowed?).to be true }
    it { is_expected.to redirect_to(action: :index) }
  end

  describe 'POST browse' do
    let(:book) { create(:book, :with_library_statuses) }

    before { post :browse, id: book.id }
    
    it { expect(assigns(:book).meta.browsed?).to be true }
    it { is_expected.to redirect_to(action: :index) }
  end

  describe 'POST rate' do
    let(:book) { create(:book, :with_library_statuses) }
    let(:rating) { 4 }

    before { post :rate, id: book.id, rating: rating, format: :json }
    
    it { expect(assigns(:book).meta.rating).to eq rating }
    it { is_expected.to respond_with(:ok) }
  end    
end
