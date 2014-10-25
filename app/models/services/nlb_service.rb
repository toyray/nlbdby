require 'open-uri'

class NLBService
  def self.import_book(brn)
    doc = Nokogiri::HTML(open("http://www.nlb.gov.sg/newarrivals/item_holding.aspx?bid=#{brn}"))
  end
end
