require "dm-core"

require "dm-migrations"
require "dm-validations"
require "lib/book-parser"


require "bookcrawler"

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/books.db")

class Book

	include DataMapper::Resource
	
	# 
	#
	#
	
	# association
	belongs_to :publisher, :required => false
	
	property :id,	Serial
	property :name,	String
	property :description, Text
	property :author,	String
	property :translator, String
	property :isbn13,	String, :required => true
	
	property :published, Boolean, :default => false
	property :published_at, DateTime
	property :created_at, DateTime
	
	# Validation 
	validates_uniqueness_of :isbn13
	
	# class Methods
	
	def self.searchByISBN(isbn)
		
		book = Book.first(:isbn13 => isbn)
		
		if book
			
			return book if book.published
			
		else
		
			# add new book
			book = Book.new
			book.isbn13 = isbn
			book.save
			return nil
		end
		
	end
	
	
	def self.updateBooks
		
		books = Book.all(:published => false)
		
		book_crawler = Bookcrawler.new
		
		
		books.each do |book|
			
			# fetch book data
			next if book.isbn13.empty?
			book_data = book_crawler.GetBookData(book.isbn13)
			book.name = book_data[:name]
			book.author = book_data[:author]
			book.translator = book_data[:translator]
			book.published_at = book_data[:date]
			book.save
			
		end
		
	end

	
	
	# instance Methods
	
	def data
		book_hash = self.attributes
		book_hash.delete(:id);
		book_hash.delete(:publisher_id);
		book_hash
	end
	
	def published?
		return published
	end
	
	
	def updateDataByEslite
		
		unless isbn13.empty?
			bookdata = Eslite::getBook(isbn13)
			self.name = bookdata[:name]
			self.author = bookdata[:author]
			self.translator = bookdata[:translator]
			self.save
			
		end
		
		
		self
		
		
	end

	
end

class Publisher

	include DataMapper::Resource
	
	# association
	has n, :books
	
	property :id,	Serial
	property :name,	String
	property :address, String
	property :phone, Integer
	property :created_at, DateTime
	
end

class Bookqueue
	
end


DataMapper.auto_upgrade!