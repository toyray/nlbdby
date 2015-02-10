require 'open-uri'

class NLBService
  def import_book(brn)
    doc = Nokogiri::HTML(open(library_url(brn)))

    book = Book.new
    book.brn = brn.to_i
    
    return nil if doc.title == 'No item found'

    extract_book_details(book, doc.css('table[summary="New Arrival Titles"] tr'))
    extract_call_no(book, doc.css('table#ItemsTable tr'))
    extract_library_details(book, doc.css('table#ItemsTable tr'))
  end

  def update_book(book)
    doc = Nokogiri::HTML(open(library_url(book.brn)))

    return book if doc.title == 'No item found'

    extract_library_details(book, doc.css('table#ItemsTable tr'))
  end

  private

  def library_url(brn)
    "http://www.nlb.gov.sg/newarrivals/item_holding.aspx?bid=#{brn}"
  end

  def extract_book_details(book, info)
    book.title = info[0].at_css('font').content.split('/').first.strip

    details = info[1].at_css('table').css('tr')
    book.author = details[1].css('td')[1].content.gsub("\u00A0", "")

    physical_info = details[5].css('td')[1].content
    book.pages = physical_info[/(\d+) (p\.|pages)/] || 999
    book.height = parse_height(physical_info)

    book
  end

  def extract_call_no(book, info)
    return if book.call_no.present?

    info.shift

    info.each do |i|
      library_name, lending_type, call_info, _ = parse_library_info(i.css('td'))
      if Library.available?(library_name) && lendable?(lending_type)
        book.call_no = parse_call_no(call_info)
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
      library_name, lending_type, call_info, availability = parse_library_info(extract_library_info(i))
    
      if Library.available?(library_name) && lendable?(lending_type)
        same_index = book.library_statuses.find_index { |ls| ls[:library] == library_name }
        if same_index.present? 
          if availability && !book.library_statuses[same_index][:available]
            book.library_statuses[same_index][:available] = availability
          end
        else
          book.library_statuses << { 
            library: library_name,
            regional: Library.regional?(library_name),
            available: availability,
            singapore: /SING/.match(call_info).present?,
            reference: lending_type == 'Lending Reference'
          }
        end
      end
    end 
    book
  end

  def extract_library_info(i)
    i.css('td')
  end

  # TODO Move this to LibraryStatus class in the future 
  def lendable?(lending_type)
    lending_type.include?('Adult Lending') || lending_type == 'Lending Reference'
  end

  def parse_library_info(string)
    library_name = string[1].content
    lending_type = string[2].content
    call_info = string[3].content
    availability = string[4].content == 'Not On Loan'
    return library_name, lending_type, call_info, availability
  end

  def parse_height(string)
    height = string[/(\d+)\s*cm\.*/, 1] || 99
    height.to_i
  end

  def parse_call_no(string)
    string[/English\s+(?:(?:SING|LR|R|RSEA|Y)\s)?q*((?:\d+[\.\d]*\s)?(?:[A-Z]{1,3}))/, 1]
  end
end
