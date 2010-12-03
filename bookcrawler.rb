require "hpricot"
require "open-uri"
require "iconv"
require "json"

class Bookcrawler
	
	attr_accessor :service_url, :book_id_url
	
	def initialize()
		@service_url = "http://www.eslite.com"
	end
	
	
	def GetBookData(isbn)
	
	
		get_eslite_book_id_url(isbn)
		
		# Book Hash
		book = {}
	
		doc = Hpricot(open(@book_id_url))
	
		# 書名
		target = doc.search("#ctl00_ContentPlaceHolder1_lblProductName")
		book[:name] = target.inner_text
	
	
		# 作者
		target = doc.search("#ctl00_ContentPlaceHolder1_CharacterList_ctl00_CharacterName_ctl00_linkName")
		book[:author] = target.inner_text
	
		# 譯者
		target = doc.search("#ctl00_ContentPlaceHolder1_CharacterList_ctl01_CharacterName_ctl00_linkName")
		book[:translator] = target.inner_text
	
	
		# Parse 沒有id的欄位
		targets = doc.search("div.PI_info h3.PI_item")
		targets.each do |t|
			content = t.inner_text
			book[:publisher] = parseRow(content, "出版社") unless book[:publisher]
			book[:date] = parseRow(content, "出版日期") unless book[:date]
			book[:published_price] = parseRow(content, "定價") unless book[:published_price]
		end
	
		# 處理金額
		if book[:published_price]
			book[:published_price] =~ /.?([1234567890]+)/
			book[:published_price] = $1
		end
	
		# add isbn to hash
		book[:isbn] = isbn
	
	  book
	
	end


	
private

	def get_eslite_book_id_url(isbn)
		 
		 url = "#{service_url}/search_pro.aspx?query=#{isbn}"
		 doc =  Hpricot(open(url))
		 result = doc.search("h3.tn15 a")
		 pgid_url = result[0].attributes["href"]
		 @book_id_url = "http://www.eslite.com/#{pgid_url}"
		 
	end
	
	# Parse "  xxxx ／ yyyyy"
	def parseRow(content, keyword)
		if !content.scan(keyword).empty?
			content =~ /(.*)\／(.*)/
			target = $2
			target = target.slice!(2..target.length)
		end
		target = target || nil
	end
	
end
