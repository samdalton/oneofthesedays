# Without the array, programming would be terribly difficult. To store 10 items, you would need 10 different variable names, and any more than this makes things hopelessly inefficient. The array lets us store a number of items under a single variable name. We can reference a specific item simply by saying which variable it's stored in, and in what position it lies. Like in C and PHP, Ruby starts indexing at 0. myArray[0] will give you the first element. In C, if you tried to access myArray[-1] you would meet a nasty runtime error. In Ruby, however, a negative index is treated as an index relative to the end of the array. Thus -1 becomes the last element, -2 the second to last, and so on.

# <a href='http://ruby-doc.org/core/classes/Array.html'>Ruby's Array class</a> has a lot of methods, so let's get right in to it and explore some of what it has to offer.

# <h3>Creation</h3>
puts [1, 2, 3]
#=>1
#=>2
#=>3


# That's all it takes! The square brackets let Ruby know that we want to create a new array, with the elements set to be the contents of the brackets. This syntax is an alias of the actual method, [].
puts Array.[](1,2,3)
#=>1
#=>2
#=>3


# If we want to create an array, but we don't have anything to store in it yet, we can use the 'new' method.
Array.new


# If we know that we want to store n items, we can create the array with a capacity.
Array.new(10).size
#=>10


# Size is a method of array which returns the number of elements. We created an empty array with space for 10 elements, and that is the size of the array.

# <h3>Generation</h3>
# The Array class gives us a powerful way of generating elements using a block. 
even = Array.new(5) { |i| i + i }
puts even # 0 2 4 6 8
    
# We have created an array called 'even' that contains the first 5 even numbers. Firstly, we stated that we wanted a new array of size 5
Array.new(5)
 

# Secondly, we put a block at the end of it.
{ |i| i + i }


# This could also be written as
do |i| i + i end


# What is this voodoo magic, do I hear you ask? Well, the block is taking a number, i, and returning the sum of i with itself. The value of i that is passed is the index into each element created. Thus for an array of size 5, we will have the indices 0, 1, 2, 3, and 4. Working this out the long way gives us
even = Array.new(5)
even[0] = 0 + 0
even[1] = 1 + 1
even[2] = 2 + 2
even[3] = 3 + 3
even[4] = 4 + 4


# Using a block lets us define each element programatically, based on the the index of that element. Nifty!

# <h3>Interesting Methods</h3>
# There are a lot of methods in the API, and most of them have some sample code to go with them. Therefore, I will look at some of the more interesting ones.

# <h4>*</h4>
# While this method can be used to duplicate an array n times, like so
['echo'] * 3 # echo echo echo


# the more interesting usage is as a join operator. PHP offers the join() method which, given an array and a character will return a string consisting of each array element, followed by the given character. Ruby also has a join method, but the * operator is a great shortcut.
['c','s','v'] * ','# c,s,v


# <h4>abbrev</h4>
# The API states that this method 'calculates the set of unambiguous abbreviations for the strings in self'. The example given, while sensible, doesn't relate to a particularly useful application. 
require 'abbrev'
%w{ car cone }.abbrev   
{ "ca" => "car", "car" => "car", "co" => "cone", "con" => "cone", "cone" => "cone" }


# Note that this method isn't part of the core API, and so it needs to be explicitly included

# So why is this useful? The main application I can see for this is auto-completion. Given a set of names or commands, what are the fewest characters I can type to identify one in particular? Consider a lazy person using twitter. If I want to send a message someone, I don't really want to type out their whole user id. Given an array of people I follow, abbrev can generate a list of possible abbreviations such that each abbreviation will only reference one person.
tweeps = ['jeff', 'steve', 'frank', 'james', 'stephen']
p tweeps.abbrev
{"frank"=>"frank",
 "stephe"=>"stephen",
 "jam"=>"james",
 "jef"=>"jeff",
 "steve"=>"steve",
 "step"=>"stephen",
 "ja"=>"james",
 "fr"=>"frank",
 "je"=>"jeff",
 "jame"=>"james",
 "f"=>"frank",
 "stephen"=>"stephen",
 "jeff"=>"jeff",
 "fran"=>"frank",
 "stev"=>"steve",
 "james"=>"james",
 "steph"=>"stephen",
 "fra"=>"frank"}


# Steve and Stephen have the same first 3 characters, and so you can see that the shortest abbreviation for each is stev and step. You may have noticed that I used 'p' and not 'puts'. This is because abbrev doesn't return an array, but a hash of 'abbreviation' => 'originalString' pairs.

# <h4>collect</h4>
# This method is similar to the element generation described above. Given an array, place a block at the end which takes each element of the array. In this case, instead of the index being passed in, the actual element is passed in. The resulting value can either be stored back in the array, or placed into a new array.
numbers = [1,2,3,4,5,6,7,8,9]
p numbers.collect { |x| if (x % 2 == 0); x; end }.compact# [2, 4, 6, 8]


# By checking if each number is divisible by 2, we can create a new array containing only the even numbers. 'compact' is used to remove elements that are 'nil'. As collect will create a new array of the same size, when the number is odd no value will be returned and so that element will be empty. To overwrite the array instead of creating a new one, use the exclamation mark.
Array.collect!


# <h4>uniq</h4>
# By using uniq you can quickly make your array behave like a set. 
p [1,1,2,2,3,4].uniq# [1, 2, 3, 4]


# <h2>Enumerable</h2>
# Now that we have a basic understanding of Array, let's take a look at it's cousin class: Enumerable. Enumerable is all about iterating. The collect method that we have just seen is an example of an Enumerable function. Collect lets you perform some operation on each element of an array. Sorting is another example of what you can do with Enumerable. The key difference between Array and Enumerable however, is that while you may create an array, you don't create an enumerable. Rather, by defining certain methods, a class can behave like an enumerable object. Before we look at how to do that, let's see some of the methods available.

# <h4>inject</h4>
# The inject method is similar to collect, but an extra value is sent to the block at each iteration containing the result of the previous iteration. This lets us compute the factorial of a number in a neat way:
p (1..4).inject { |sum, n| sum + n }# 10
4! = 10.

# <h4>sort</h4>
# When we have an array of elements, we quite often want to sort them. It they are names, we'd like to sort them alphabetically; if they are numbers, well, numerically would make sense. The sort method gives us great flexibility when it comes to sorting by letting us define the sorting comparator as a block.
p %w{a c b}.sort { |a, b| a < => b }# ["a", "b", "c"]

# %w{a c b} is a short way of saying ['a', 'c', 'b']. If each element of your array is a single word, then the shorthand will be quicker as you don't have to worry about typing in quotes. So, given our array, ['a', 'c', 'b'] and our block, { |a,b| a < => b }, we see that they have become alphabetically sorted. The block operates on a pair of values, and compares them with the < => operator. < => returns -1 if the left value is lesser, 0 if they are equal, and +1 if the left value is greater. If we want to sort the array in reverse order, we simply swap the order of the values in our block.

p %w{a c b}.sort { |b, a| a < => b }# ["c", "b", "a"]


# <h3>Custom Enumerable Classes</h3>
# If you have your own class, you may want to do things with it as if it were an array. For example, let's say we have a BookShelf class that maintains records of various books we own. One thing we may like to do is print out our books sorted by their author. If we include Enumerable into our BookShelf class, and define the method 'each', we will be able to write code that might look like the following.
p bookShelf.sort { |a,b| a['author'] < => b['author'] }
    [{"title"=>"Great Expectations", "author"=>"Dickens, C."},
    {"title"=>"Linchpin", "author"=>"Godin, S."},
    {"title"=>"Frankenstien", "author"=>"Shelly, M."}]

# As you can see, we have an array of hashes, containing an author and a title. They are ordered by the author's name. Here's the BookShelf class that lets us do this.

class BookShelf
    include Enumerable

    def initialize
        @titles = []
        @authors = []
    end

    def add bookTitle, bookAuthor
        @titles.push bookTitle
        @authors.push bookAuthor
    end

   def each
       @authors.each_with_index do |author, index| yield 'author' => author, 'title' => @titles.fetch(index)  end
   end    
end

# We are including the Enumerable class, which means that if we define the method, 'each', we can call any Enumerable method on the BookShelf class.

# The each method is defined as
@authors.each_with_index do |author, index| yield 'author' => author, 'title' => @titles.fetch(index)  end

# In English, this says 'For each author, get me the name of the author and the index. Then I'm going to stop (yield) and return the name of the author, and the title of the book that appears in the same position in the titles array'. As you can see, it is 'yield' that is doing the magic here. It essentially stops the loop (each_with_index) and spits out the result of the statements that follow it. 

# If you want to try it out yourself, you could add some books to the BookShelf like so
bookShelf = BookShelf.new
bookShelf.add 'Great Expectations', 'Dickens, C.'
bookShelf.add 'Frankenstien', 'Shelly, M.'
bookShelf.add 'Linchpin', 'Godin, S.'

# <h2>End</h2>
# Phew! That was a lot to take in. Hopefully you've seen some of the neat methods that the Array class provides, particularly 'abbrev', as well as how we can make our own classes behave like Enumerable objects. Let me know if you have any questions, comments, and especially criticisms.
