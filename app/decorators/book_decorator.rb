class BookDecorator < Draper::Decorator
  delegate_all

  def availability_badge(library_id)
    unless object.read? || object.queued? || object.available?(library_id)
      h.content_tag :span, class: 'label label-danger' do
        h.icon('frown-o', '', class: 'fa-lg')
      end
    end
  end

  def reference_badge(library_id)
    if object.reference?(library_id)
      h.content_tag :span, class: 'label label-info' do
        'REF'
      end
    end
  end

  def library_count_badge
    case object.library_count
    when 0..1
      badge_class = 'label-danger'
    when 2..5
      badge_class = 'label-warning'
    else
      badge_class = 'label-success'
    end
    h.content_tag :span, class: "label #{badge_class}" do
      if object.library_count > 9
        "9+"
      else
        "#{object.library_count}"
      end
    end
  end
end
