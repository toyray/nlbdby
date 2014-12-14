require 'open-uri'

class NLBService
  def import_book(brn)
    doc = Nokogiri::HTML(open("http://www.nlb.gov.sg/newarrivals/item_holding.aspx?bid=#{brn}"))

    book = Book.new
    book.brn = brn.to_i
    
    return nil if doc.title == 'No item found'

    extract_book_details(book, doc.css('table[summary="New Arrival Titles"] tr'))
    extract_call_no(book, doc.css('table#ItemsTable tr'))
    extract_library_details(book, doc.css('table#ItemsTable tr'))
  end

  private

  def extract_book_details(book, info)
    book.title = info[0].at_css('font').content.split('/').first.strip

    details = info[1].at_css('table').css('tr')
    book.author = details[1].css('td')[1].content.gsub("\u00A0", "")

    physical_info = details[5].css('td')[1].content
    book.pages = physical_info[/(\d+) (p\.|pages)/] || 0
    book.height = physical_info[/(\d+)\s*cm\./] || 0

    book
  end

  def extract_call_no(book, info)
    return if book.call_no.present?

    info.shift

    info.each do |i|
      library_info = i.css('td')

      lending_type = library_info[2].content
      call_info = library_info[3].content
      
      if !lending_type.start_with?('Accompanying')
        book.call_no = call_info[/(?:(?:SING|LR)\s)?((?:\d+[\.\d]*\s)?(?:[A-Z]{2,3}))/, 1]
        book.section = call_info[/\[([A-Z]+)\]/, 1]
        return book
      end
    end 
    book    
  end

  def extract_library_details(book, info)
    info.shift

    book.library_statuses ||= []
    info.each do |i|
      library_info = i.css('td')

      library_name = library_info[1].content
      lending_type = library_info[2].content
      call_info = library_info[3].content
      availability = library_info[4].content
      if Library.available?(library_name) && (lending_type.start_with?('Adult Lending') || lending_type == 'Lending Reference')
        book.library_statuses << { 
          library: library_name,
          available: availability == 'Not On Loan',
          singapore: /SING/.match(call_info).present?,
          reference: lending_type == 'Lending Reference'
        }
      end
    end 
    book
  end
end
