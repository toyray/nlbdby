require 'open-uri'

class NLBService
  def import_book(brn)
    doc = extract_book(brn)
    return nil unless valid_book_doc?(doc)

    book = Book.new
    book.brn = brn.to_i

    book_details = find_book_details(doc)
    library_details = find_library_details(doc)

    extract_book_details(book, book_details)
    extract_call_no(book, library_details)
    extract_library_details(book, library_details)
  end

  def update_book(book)
    doc = extract_book(book.brn)
    return book unless valid_book_doc?(doc)

    library_details = find_library_details(doc)

    extract_library_details(book, library_details)
  end

  private
  def extract_book(brn)
    Nokogiri::HTML(open(library_url(brn.strip)))
  end

  def parse_height(string)
    height = string[/(\d+)\s*cm\.*/, 1] || 0
    height.to_i
  end

  def parse_pages(string)
    page = string[/(\d+) (p\.|pages)/] || 0
    page.to_i
  end

  def lendable?(lending_type)
    lending_type.include?('Lending')
  end

  def library_url(brn)
    raise 'Implement in subclass'
  end

  def find_book_details(doc)
    raise 'Implement in subclass'
  end

  def find_library_details(doc)
    raise 'Implement in subclass'
  end

  def extract_book_details(book, doc)
    raise 'Implement in subclass'
  end

  def extract_call_no(book, doc)
    raise 'Implement in subclass'
  end

  def extract_library_details(book, doc)
    raise 'Implement in subclass'
  end
end
