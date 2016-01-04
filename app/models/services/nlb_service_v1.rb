# Extracts book data via older page linked through New Arrivals page
class NLBServiceV1 < NLBService
  private
  def library_url(brn)
    "http://www.nlb.gov.sg/newarrivals/item_holding.aspx?bid=#{brn}"
  end

  def valid_book_doc?(doc)
    doc.title != 'No item found'
  end

  def find_book_details(doc)
    doc.css('table[summary="New Arrival Titles"] tr')
  end

  def find_library_details(doc)
    doc.css('table#ItemsTable tr')
  end

  def extract_book_details(book, doc)
    book.title = doc[0].at_css('font').content.split('/').first.strip

    details = doc[1].at_css('table').css('tr')
    book.author = details[1].css('td')[1].content.gsub("\u00A0", "")

    physical_info = details[5].css('td')[1].content
    book.pages = parse_pages(physical_info)
    book.height = parse_height(physical_info)

    book
  end

  def extract_call_no(book, doc)
    return if book.call_no.present?

    rows = doc.dup
    rows.shift

    rows.each do |r|
      library_name, lending_type, call_info, _ = parse_library_info(find_library_info(r))
      if Library.available?(library_name) && lendable?(lending_type)
        book.call_no = parse_call_no(call_info)
        book.section = call_info[/\[([A-Z]+)\]/, 1]
        return book
      end
    end
    book
  end

  def extract_library_details(book, doc)
    rows = doc.dup
    rows.shift

    book.library_statuses ||= []
    rows.each do |r|
      library_name, lending_type, call_info, availability = parse_library_info(find_library_info(r))

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

  def find_library_info(doc)
    doc.css('td')
  end

  def parse_library_info(doc)
    library_name = doc[1].content
    lending_type = doc[2].content
    call_info = doc[3].content
    availability = doc[4].content == 'Not On Loan'
    return library_name, lending_type, call_info, availability
  end

  def parse_call_no(string)
    string[/English\s+(?:(?:SING|LR|R|RSEA|Y)\s)?q*((?:\d+[\.\d]*\s)?(?:[A-Z]{1,3}))/, 1]
  end
end
