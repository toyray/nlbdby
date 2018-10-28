# Extracts book data via newer Spydus page linked through catalogue
class NLBServiceV2 < NLBService
  private
  def library_url(brn)
    "https://catalogue.nlb.gov.sg/cgi-bin/spydus.exe/ENQ/EXPNOS/BIBENQ?BRN=#{brn}"
  end

  def valid_book_doc?(doc)
    find_book_details(doc).present?
  end

  def find_book_details(doc)
    doc.at_css('form[name="frmSVL"] tr > td:nth-child(2) table')
  end

  def find_library_details(doc)
    doc.css('div.holdings table.clsTab1:last tr')
  end

  def extract_book_details(book, doc)
    rows = doc.css('tr')

    title = extract_field(rows, "Title").try(:content) || ''
    book.title = title.split('/').first.strip

    authors = extract_field(rows, "Creator")
    if authors
      authors = authors.css('a')
      book.author = authors.first.content[/[A-Za-z\. ]*, [A-Za-z\. ]*/, 0] || ''
    else
      book.author = ''
    end

    physical_info = extract_field(rows, 'Physical Description').try(:content) || ''
    book.pages = parse_pages(physical_info)
    book.height = parse_height(physical_info)

    book
  end

  def extract_field(doc, field)
    field = doc.at_css("span:contains('#{field}')")
    if field.present?
      field = field.parent.parent
      field.at_css('td:nth-child(3)')
    end
  end

  def extract_call_no(book, doc)
    return if book.call_no.present?

    rows = doc.dup
    rows.shift

    rows.each do |r|
      library_name, lending_type, call_no, section, _ = parse_library_info(find_library_info(r))
      if Library.available?(library_name) && (Library.non_reference?(library_name) || lendable?(lending_type))
        book.call_no = call_no
        book.section = section
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
      library_name, lending_type, _, _, availability = parse_library_info(find_library_info(r))

      if Library.available?(library_name) && (Library.non_reference?(library_name) || lendable?(lending_type))
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
            singapore: lending_type == 'Adult Lending Singapore Col.',
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
    book_meta = doc[1].at_css('book-location')

    library_name = doc[0].at_css('a').content
    lending_type = book_meta['data-defaultloc']
    call_no = book_meta['data-callnumber']
    section = book_meta['data-itemcategory']
    section = nil if section == ''
    availability = doc[3].content == 'Available'

    return library_name, lending_type, call_no, section, availability
  end
end
