class Book < ActiveRecord::Base
  validates_presence_of :brn,
                        :title,
                        :author,
                        :pages,
                        :height,
                        :call_no
end
