# Welcome to the first instalment of 0 to Ruby in 30 days. Today will cover a simple, but useful class: Date.

# Most web applications that let users contribute content will likely require the use of date and time functionality. Just consider how useful would a website be that helps people coordinate meetings if there was no way of specifying the time? Also consider how difficult it would be to coordinate a global event, with people in different time zones, if everyone saw the time in GMT +0. Confusion (and possibly hilarity) would undoubtably ensue. Clearly, we need a way to handle dates and times.

# Slightly strange motivation aside, let's get started. The format of this tutorial is as follows: I have opened the <a href="http://ruby-doc.org/core/classes/Date.html">API reference for the Date class</a> and will be going through it, testing methods of interest. I have not used the date class before and so at each step, I am guessing the usage based on my limited experience of Ruby gained from <a href="http://mislav.uniqpath.com/poignant-guide/book/chapter-1.html">_Why's (Poignant) Guide</a>. You can consider this tutorial, then, to be an extra reference to the API page, with examples of usage and results of various important methods.

# One of the major differences between the Ruby date library and the PHP date library is the epoch used. PHP uses the date 'January 1 1970 00:00:00 GMT', the beginning of UNIX, as a reference point. Time is defined as the number of seconds after or before this time. Ruby uses January 1, 4713 BC as its reference point. This is known as the Julian Date, with any date defined by the number of days before or after this reference point. But this is a programming tutorial, not a history lesson, so let's see some code.


# Great! We can create a new date object by providing the year, month and day. (Date.new and Date::new seems to function identically). By printing it to the console with puts, we can see that, indeed, this Date object contains the date we specified.
d = Date.new(2010, 6, 22)   
puts d                      # 2010-06-22


# Lets get specific parts of the date
puts d.month    # 6
puts d.day      # 22
puts d.year     # 2010


# <strong>cwday</strong>
# The method 'cwday' gives the Commercial day of the week
# Today is Tuesday, the 2nd day of the working week. Sunday is 7, the last day of the week.
puts d.cwday    # 2


# What happens when we create an invalid date?
d = Date.new(0325, 14, 45)  # ArgumentError: invalid date

# We have a basic understanding, so let's start looking at some of the class methods

# <strong>day_fraction_to_time</strong>
puts Date.day_fraction_to_time(0.75) # 18003.72423446248771e-17

# This is equal to 18 hours, 00 minutes, 03 seconds, 0.72.. milliseconds


# <strong>time_to_day_fraction</strong>
puts Date.time_to_day_fraction(18,00,03)    # 21601/28800

# 21601/28800 turns out to be 0.75, the fraction we passed in to day_fraction_to_time. 


# <strong>today</strong>
puts Date.today # 2010-06-22


# <strong>valid_time</strong>
puts Date.valid_time?(25,0,0)   # nil

# 25 hours is not a valid time, hence the result is nil.

# **-**
# The - operator should return a date that is n days earlier than the current one
d = Date.today
puts d - 3  # 2010-03-19

# \+ adds days in the same way

# <strong><<</strong>
# The << operator should return a date that is n months earlier than the current one
d = Date.today
puts d < < 3    # 2010-03-22

# &gt;&gt; adds months in the same way

# <strong>leap?</strong>
# Is this a leap year?
d = Date.today
puts d.leap?    # false
# go back 2 years
d = d < < 24    
puts d.leap?    # true


# <strong>next</strong>
# The next day.
d = Date.today
puts d.next     # 2010-06-23


# So, that's the Date class. Pretty nifty, and very intuitive. But what good is the date without the time? Enter: DateTime
t = DateTime.new
puts t  # -4712-01-01T00:00:00+00:00


# Looks like that wasn't sufficient, but note the term '-4712'. This was the year Ruby set to be the reference time. 
t = DateTime.now
puts t  # 2010-06-22T13:56:13+12:00


# There we go
# 2010-06-22 is the date
# T demarcates the time 
# 13:56:13 is the current time
# +12:00 is the time zone. I live in New Zealand which is GMT +12

# Let's just check that the timezone is correct
puts t.zone # +12:00


# Now we've seen some of the various methods, lets put it to use in a practical example. If you're developing a website, chances are you'll be dealing with people from all over the world. This means you'll be dealing with different time zones, and so every time you work with a date and time you must ensure you have the timezone correct. Let's imagine you're developing 'Qwitter', a social networking service designed for people who are trying to ween themselves off Twitter. When someone updates their status, their followers want to see the time in their own timezone, so lets define a function to convert a time from a certain timezone, into another 
def time_relative_to_timezone (oldTime, newTimeZone)
    oldTimeZone = time.offset    
    oldTimeZone *= 24

    timeZoneDifference = oldTimeZone - newTimeZone

    time - (timeZoneDifference / 24)
end


# We can call it like so:
puts time_relative_to_timezone(DateTime.now, -5)


# So, what's going on there? Firstly, we are taking the given time and finding it's timezone. The 'offset' method returns the timezone as a fraction of 24 hours. 0.5 would be 12 out of 24, for a timezone difference of +12. Thus, if we multiply this fraction by 24, we get the timezone offset in hours.

# We then find the difference between this timezone, and the supplied one. We will assume for arguments sake (no pun intended) that the supplied timezone is already an offset given in hours. By subtracting them, we find how different they are.

# Lastly, recall that when used with a DateTime object, the - operator subtracts a number of days. If we subtract our time zone difference as a fraction of 24 hours (1 day), we will end up with a new DateTime object with a time that has been adjusted.

# Obviously we would need to include error handling for invalid arguments, but this has been ocluded for clarity.


# <strong>End</strong>
# Hopefully this tutorial has shed some light on the Ruby Date, and DateTime classes. If you have any questions, comments, criticisms, praise, please leave a comment or send me an email.
