require 'rails_helper'

RSpec.describe BooksController, :type => :controller do
  shared_examples_for 'render row or redirect' do
    context 'when format is html' do
      let(:format) { :html }

      it { is_expected.to redirect_to(action: :index) }
    end

    context 'when format is js' do
      let(:format) { :js }

      it { is_expected.to render_template(partial: '_render_row') }
    end
  end

  shared_examples_for 'remove row or redirect' do
    context 'when format is html' do
      let(:format) { :html }

      it { is_expected.to redirect_to(action: :index) }
    end

    context 'when format is js' do
      let(:format) { :js }

      it { is_expected.to render_template(:remove) }
    end
  end

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

      it { is_expected.to_not set_session[:search_library_id] }
    end

    context 'when library_books_library_id_eq is not blank' do
      let(:params) { { q: { library_books_library_id_eq: '1' } } }

      it { is_expected.to set_session[:search_library_id].to("1") }
    end

    context 'when library_books_library_id_eq is blank' do
      let(:params) { { q: { library_books_library_id_eq: '' } } }

      it { is_expected.to_not set_session[:search_library_id] }
    end
  end

  describe 'GET new' do
    before { get :new }

    it { is_expected.to render_template(:new) }
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
        expect(flash[:alert]).to_not be_nil
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
    let(:format) { :html }

    before do
      expect_any_instance_of(Book).to receive(:update_availability_async)
      post :queue_update, id: book.id, format: format
    end

    it { expect(assigns(:book).queued?).to be true }
    it_behaves_like 'render row or redirect'
  end

  describe 'GET show' do
    let(:book) { create(:book, :with_library_statuses) }

    before { get :show, id: book.id }

    it { is_expected.to render_template(:show) }
  end

  describe 'POST borrow' do
    let(:book) { create(:book, :with_library_statuses) }
    let(:format) { :html }

    before { post :borrow, id: book.id, format: format }

    it { expect(assigns(:book).meta.borrowed?).to be true }
    it_behaves_like 'render row or redirect'
  end

  describe 'POST browse' do
    let(:book) { create(:book, :with_library_statuses) }
    let(:format) { :html }

    before { post :browse, id: book.id, format: format }

    it { expect(assigns(:book).meta.browsed?).to be true }
    it_behaves_like 'render row or redirect'
  end

  describe 'POST rate' do
    let(:book) { create(:book, :with_library_statuses) }
    let(:rating) { 4 }

    before { post :rate, id: book.id, rating: rating, format: :json }

    it { expect(assigns(:book).meta.rating).to eq rating }
    it { is_expected.to respond_with(:ok) }
  end

  describe 'DELETE destroy' do
    let(:book) { create(:book, :with_library_statuses) }
    let(:format) { :html }

    before { delete :destroy, id: book.id, format: format }

    it { expect(Book.exists?(book.id)).to be false }
    it_behaves_like 'remove row or redirect'
  end

  describe 'POST revert_to_new' do
    let(:book) { create(:book, :with_library_statuses) }
    let(:format) { :html }

    before do
      book.meta.browse
      post :revert_to_new, id: book.id, format: format
    end

    it { expect(assigns(:book).meta.new?).to be true }
    it_behaves_like 'render row or redirect'
  end

  describe 'POST toggle_starred' do
    let(:book) { create(:book, :with_library_statuses) }
    let(:format) { :html }

    before { post :toggle_starred, id: book.id, format: format }

    it { expect(assigns(:book).reload.meta.starred?).to be true }
    it_behaves_like 'render row or redirect'
  end

  describe '#search_params' do
    subject { controller.send(:build_search_params, params) }

    context 'when no search params are specified' do
      let(:params) { {} }

      it { is_expected.to include(meta_status_not_in: [:borrowed, :archived]) }
    end

    context 'when searching for non solo books' do
      let(:params) { { library_count_eq: '-1' } }

      it { is_expected.to include(library_count_not_eq: 1) }
      it { is_expected.to_not include(:library_count_eq) }
    end

    context 'when searching for regional only books' do
      let(:params) { { regional_only: '1' } }

      it { is_expected.to include(non_regional_library_count_eq: 0) }
      it { is_expected.to_not include(:regional_only) }
    end

    context 'when searching for non-regional only books' do
      let(:params) { { regional_only: '-1' } }

      it { is_expected.to include(non_regional_library_count_not_eq: 0) }
      it { is_expected.to_not include(:regional_only) }
    end

    context 'when library is selected' do
      let(:library_params) { { library_books_library_id_eq: '1' } }

      context 'when searching for available books' do
        let(:params) { library_params.merge({ available: '1' }) }

        it { is_expected.to include(library_books_available_eq: true) }
        it { is_expected.to_not include(:available) }
      end

      context 'when searching for unavailable books' do
        let(:params) { library_params.merge({ available: '-1' }) }

        it { is_expected.to include(library_books_available_eq: false) }
        it { is_expected.to_not include(:available) }
      end
    end

    context 'when no library is selected' do
      context 'when searching for available books' do
        let(:params) { { available: '1' } }

        it { is_expected.to include(available_count_not_eq: 0) }
        it { is_expected.to_not include(:available) }
      end

      context 'when searching for unavailable books' do
        let(:params) { { available: '-1' } }

        it { is_expected.to include(available_count_eq: 0) }
        it { is_expected.to_not include(:available) }
      end
    end

    context 'when library_count is specified' do
      context 'when searching for solo books' do
        let(:params) { { library_count: '-1' } }

        it { is_expected.to include(library_count_lt: 2) }
        it { is_expected.to_not include(library_count: -1) }
      end

      context 'when searching for uncommon books' do
        let(:params) { { library_count: '-2' } }

        it { is_expected.to include(library_count_in: 2..5) }
        it { is_expected.to_not include(library_count: -1) }
      end

      context 'when searching for common books' do
        let(:params) { { library_count: '-3' } }

        it { is_expected.to include(library_count_gt: 5) }
        it { is_expected.to_not include(library_count: -1) }
      end
    end
  end

  describe 'POST archive' do
    let(:book) { create(:book, :with_library_statuses) }
    let(:format) { :html }

    before do
      book.meta.borrow
      post :archive, id: book.id, format: format
    end

    it { expect(assigns(:book).meta.archived?).to be true }
    it_behaves_like 'remove row or redirect'
  end

  describe 'summary' do
    before { xhr :get, :summary }

    it { is_expected.to render_template(:summary) }
  end
end
