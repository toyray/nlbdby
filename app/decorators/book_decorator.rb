class BookDecorator < Draper::Decorator
  delegate_all

  def availability_status(library_id)
    object.available?(library_id) ? 'YES' : 'NO'
  end

  def reference_status(library_id)
    if object.reference?(library_id)
      h.content_tag :span, class: 'label label-info' do
        'REF'
      end
    end
  end
end
