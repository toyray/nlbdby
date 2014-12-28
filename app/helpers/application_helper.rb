module ApplicationHelper
  def attr_row(object, attribute)
    content_tag(:tr) do
      concat content_tag(:td, object.class.human_attribute_name(attribute), class: 'col-xs-4')
      concat content_tag(:td, object.try(attribute) || '', class: 'col-xs-8')
    end
  end

  def bootstrap_alert_class(flash_type)
    case flash_type.try(:to_sym)
    when :alert
      'alert-danger'
    when :notice
      'alert-success'
    else
      'alert-info'
    end
  end
end
