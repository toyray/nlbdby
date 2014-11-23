module ApplicationHelper
  def attr_row(object, attribute)
    content_tag(:tr) do
      concat content_tag(:td, object.class.human_attribute_name(attribute), class: 'col-xs-4')
      concat content_tag(:td, object.try(attribute) || '', class: 'col-xs-8')
    end
  end
end
