require "rubygems"

require "hpricot"
require "open-uri"
require "iconv"
require "json"


#  Eslite Book Store's Steal Methods
#		
#		Using Example
#			
#			Eslite.getBook("9789868646711")
#			
#			Return : Book hash Object
#
# puts Eslite.getBook("9789861203348")


module Eslite

	@@book = {}

	def self.getBook(isbn)
	
		url = getBookID(isbn)
		
		# Book Hash
		book = {}
	
		doc = Hpricot(open(url))
	
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
	
		return book

	end
	
	
	def self.getBookID(isbn)
		url = "http://www.eslite.com/search_pro.aspx?query=#{isbn}"
		doc = Hpricot(open(url))
		result = doc.search('h3.tn15 a')
		pgid_url = result[0].attributes["href"]
		pgid_full_url = "http://www.eslite.com/#{pgid_url}"
	end
	
	
	# Parse "  xxxx ／ yyyyy"
	def self.parseRow(content, keyword)
		
		if !content.scan(keyword).empty?
			content =~ /(.*)\／(.*)/
			target = $2
			target = target.slice!(2..target.length)
		end
		target = target || nil

	end
	
	
end


#puts Eslite.getBook("9789861203348")

