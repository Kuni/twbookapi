
require "rubygems"
require "sinatra"
require "model"

require "isbn/tools"
require "json"

# Sinatra

get '/' do
	" The Best Open BOOK API @ Taiwan"
end


# Search : Result (Return ISBN13 Array)
get "/search" do
	search_result =  search_result || []
	return search_result.to_json
end


# ISBN : Return Book Data
# if isbn exist return BOOK data , else return empty json string
#	
#
get "/isbn/:isbn" do
	
	empty = {}
	
	isbn = params[:isbn]
	# Step 1 : 
	#		1.1 Check isbn is valid ?
	unless ISBN_Tools.is_valid?(isbn)
		return empty.to_json
	end
	
	# Convert ISBN10 to ISBN13
	isbn = ISBN_Tools.isbn_10_to_isbn13(isbn) if isbn.length == 10
	
	#	Step 2 : Is ISBN13 exist in Database?
	#					 If ISBN13 is Exist then to Return BOOK Data, else to Add new book?
	
	book = Book.searchByISBN(isbn)
	
	if book
		return book.data.to_json
	else
		return empty.to_json
	end	
	
end


# cron schedule
get "/cron/updateBookData" do
	
end





################# Book API Admin #############












