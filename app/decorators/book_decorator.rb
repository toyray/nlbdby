class BookDecorator < Draper::Decorator
  delegate_all

  def availability_status(library_id)
    unless object.available?(library_id)
      h.content_tag :span, class: 'label label-danger' do
        h.icon('frown-o', '', class: 'fa-lg')
      end
    end
  end

  def reference_status(library_id)
    if object.reference?(library_id)
      h.content_tag :span, class: 'label label-info' do
        'REF'
      end
    end
  end
end
