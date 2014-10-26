require 'open-uri'

class NLBService
  def import_book(brn)
    doc = Nokogiri::HTML(open("http://www.nlb.gov.sg/newarrivals/item_holding.aspx?bid=#{brn}"))

    book = Book.new
    book.brn = brn.to_i

    extract_book_details(book, doc.css('table[summary="New Arrival Titles"] tr'))
    extract_library_details(book, doc.css('table#ItemsTable tr'))
  end

  private

  def extract_book_details(book, info)
    book.title = info[0].at_css('font').content.split('/').first.strip

    details = info[1].at_css('table').css('tr')
    book.author = details[1].css('td')[1].content

    physical_info = details[5].css('td')[1].content
    book.pages = physical_info[/(\d+) (p\.|pages)/] || 0
    book.height = physical_info[/(\d+)\s*cm\./] || 0

    book
  end

  def extract_library_details(book, info)
    info.shift

    book.library_statuses ||= []
    info.each do |i|
      library_info = i.css('td')

      #TODO: Ignore certain libraries
      lending_type = library_info[2].content
      if lending_type == 'Adult Lending' || lending_type == 'Lending Reference'
        book.library_statuses = { 
          library: library_info[1].content,
          available: library_info[4].content == 'Not On Loan'
        }
      end

      if book.call_no.nil?
        call_info = library_info[3].content
        book.call_no = call_info[/(\d+\.\d+ [A-Z]{3})/]
        book.section = call_info[/\[([A-Z]+)\]/, 1]
      end
    end 
    book
  end
end
