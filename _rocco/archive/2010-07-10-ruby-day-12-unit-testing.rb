# <em>Before we get into unit testing in Ruby, I should apologise for the inconsistent posting of content. Amidst other work commitments, writing 1 post per day for 30 days is proving to be quite a challenge. I imagine at the end of this I will be able to write a post on "How Not to Write a Blog Post Series". (Here's a tip now: start writing at least a week before you start publishing)</em>

# We have a reasonable HTTP server working for us now. It can handle multiple simultaneous requests, log important information out to a file, and handle query parameters in the requested URL. While we can see that it works by running it, it would be good to have a more thorough test which we can run often and easily to ensure that any future changes do not break it. We will be using the <a href="http://ruby-doc.org/core/classes/Test/Unit.html" title="Module: Test::Unit">Ruby Unit Testing Framework</a> to achieve this.

# Writing unit tests is a bit like using source control. Once you've set it up and are using it regularly, your level of sanity is slightly higher than if you weren't using it. Similarly, once you've written some good unit tests, they will always be there for you to check that your code runs ok. An example of where a good set of unit tests would be handy is in a series of text manipulation operations. On a UNIX machine you may simply be checking for the existence of '\n' for newlines, but if the same code is run on a Windows machine it may fail. By running the tests on each new machine, issues like this will become apparent with very little extra effort.

# As the synchronised buffer is a crucial component of the multi-threaded web server, we will create a set of unit tests specifically to test this class.

# A unit test class at its most basic looks like this:
class SyncBufferTest < Test::Unit::TestCase
	def test1
		assert(true)
	end
end

# We are simply extending from the 'Test::Unit::TestCase' class and then defining our test in the method 'test1'. There is a convention that must be followed for defining new tests, but it is a simple one: each method must begin with 'test'. You can have whatever you like afterwards, but with 'test' at the front Ruby will know this is to be treated as a test case. The following are all valid test case names:
test1
test_my_test
test_if_exception_thrown
test123ABC

# In order to examine more of the Ruby Unit Test API, we will need to make a quick addition to the SynchronisedBuffer class. Add the following  line to the beginning of the initialize method. (i.e. before @capacity = capacity)
raise "Capacity must be greater than 0" unless capacity > 0

#This does exactly what it says it will: raises an exception with the message "Capacity must be greater than 0" unless the capacity is greater than 0. This stops someone creating a new buffer with a capacity of 0 or -1, which simply does not make sense. We can then write test cases to check that this actually happens.

def test_zero_capacity
      begin
          SynchronisedBuffer.new(0)
      rescue 
        assert_equal("Capacity must be greater than 0", $!.message)
      end
  end

  def test_negative_capacity
      begin
          SynchronisedBuffer.new(-1)
      rescue 
        assert_equal("Capacity must be greater than 0", $!.message)
      end
  end

# 'test_zero_capacity' and 'test_negative_capacity' are testing this line we just added in above. An exception should be thrown when the supplied capacity is less than or equal to 0. By using the error handling begin/rescue syntax we can catch any exceptions thrown. In the rescue section, we are calling  'assert_equal' which is a method provided by Test::Unit::TestCase to ensure that 2 values are equal. It is by convention that the expected value comes before the actual value, thus we are seeing if "Capacity must be greater than 0" is equal to the message contained in the thrown exception. '$!' is a global variable that contains the most recently thrown exception, and the message method returns the message that the exception contains.

# If we now run this file we should see output like below
# ![Test output](/uploads/2010/07/Screen-shot-2010-07-09-at-11.24.10-PM.png)

# A dot, '.', represents a test that has passed. We can see results in a sentence as well, '2 tests, 2 assertions, 0 failures, 0 errors'. We have 2 tests that asserted 1 statement each, and neither failed nor threw an error. If we remove the begin/rescue block from each test, and simply have 'SynchronisedBuffer.new(0)' then there would appear an 'E' for error instead of a '.' as the thrown exception is not being rescued. Alternatively, if in our SynchronisedBuffer class we did not put in the line to raise the exception, we would see an 'F' in place of a '.' as no exception is being thrown, and so no assertion is true. (This idea of writing tests that will fail before the function has actually been implemented is known as Test Driven Development).

# The trick to unit testing is finding the right set of test cases that don't overlap, but don't miss anything out, either. We have tested the capacity of 0, which is neither a positive nor a negative number. It is in a class of it's own and so we must include this test. -1, however, is a negative number just like -2 or -9,235,123. It is in a class with an infinite amount of other negative numbers. It would be impossible, and senseless, to test each negative number as we know that the condition only requires the number to be greater than 0. -1 is therefore sufficient to ensure that it will work with any negative number.

# Let's now test the empty? and full? methods.
# Here we are creating a new buffer with a valid capacity and then calling the 'assert' method. This simply checks if the value inside returns true. If it does, then the assertion is true. Without putting in any objects, empty? should return true. With a buffer of capacity 1, after putting in 1 item full? should return true.
def test_empty?
    buffer = SynchronisedBuffer.new(1)
    assert(buffer.empty?)    
end

def test_full
    buffer = SynchronisedBuffer.new(1)
    buffer.put("item 1")
    assert(buffer.full?)
end

# These tests check that full? does not return true when it shouldn't, and likewise with empty?.
def test_not_full
    buffer = SynchronisedBuffer.new(2)
    buffer.put("item 1")
    assert(!buffer.full?)
end

def test_not_empty
    buffer = SynchronisedBuffer.new(2)
    buffer.put("item 1")
    assert(!buffer.empty?)
end

# We now have some simple test cases in place, but they only ensure a limited part of the functionality. What we really want to test are the put and get methods. As these methods can potentially put to sleep the thread that calls them, we have to be careful when testing them. The scenarios we must test for are
# <ul>
	# <li>calling put while the buffer is empty</li>
	# <li>calling put while the buffer is full</li>
	# <li>calling get while the buffer is empty</li>
	# <li>calling get while the buffer is full</li>
	# <li>calling get while a thread is waiting on put</li>
	# <li>calling put while a thread is waiting on get</li>
# </ul>
# and we can translate them to the following test case names
def test_put_while_empty
end

def test_put_while_full
end

def test_get_while_empty
end  

def test_get_while_full
end

def test_get_waking_up_sleeping_thread
end

def test_get_waking_up_sleeping_thread
end

# Our first test is rather simple
# We create a new buffer with a capacity of 1. After putting in 1 item, the buffer should be full. The buffer was empty when we called put, so the current thread should not be put to sleep while waiting for the buffer to empty. Thus we are asserting that the status of the current thread is equal to 'run'. This concept of checking thread status will be very important for the rest of the test cases.
def test_put_while_empty
    buffer = SynchronisedBuffer.new(1)
    buffer.put("item 1")
    assert_equal('run', Thread.current.status)
end

# As before, we are creating a new buffer and placing in an item so it becomes full. As the buffer is full, any subsequent calls of put will cause the calling thread to sleep. As we don't want to put our main thread to sleep, we create a new thread and pass in the buffer. By calling 'put' in this thread, we expect the thread to go to sleep. The line that comes after,
def test_put_while_full
    buffer = SynchronisedBuffer.new(1)
    buffer.put("item 1")
    thread = Thread.new(buffer) { |buffer|
        buffer.put("item 2")
    }
    Thread.pass  # run 'thread' to ensure it sleeps
    assert_equal('sleep', thread.status, 'Thread should be asleep waiting to put')
    thread.kill!
end
#
# Thread.pass is important as it without it, assert_equal might be called before the new thread has had a chance to actually call 'put'. If this were the case, the thread would not yet be asleep, and so it's status would be 'run', and the test would fail. 'Thread.pass' says to the Ruby thread scheduler "I've had enough, let another thread run for a while". This would give the thread to actually call buffer.put and then we can test if it's state is set to 'sleep'. Lastly, while perhaps not necessary, we are destroying this new thread.

# Having written this test case, the subsequent ones will follow much the same pattern.

def test_get_while_empty
    buffer = SynchronisedBuffer.new(1)
    thread = Thread.new(buffer) { |buffer|
        buffer.get
    }
    Thread.pass # run 'thread' to ensure it sleeps
    assert_equal('sleep', thread.status, 'Thread should be asleep waiting to get')
    thread.kill!
end

def test_get_while_full
    buffer = SynchronisedBuffer.new(1)
    buffer.put("item 1")
    buffer.get
    assert(buffer.empty?)
end

# This last test case has a minor addition, 'thread.join'. We are testing the case when we are trying to put an item into a full buffer. This call will make the thread sleep until someone else calls 'get'. Once get is called, we want to ensure that the thread waiting actually completes calling 'buffer.put' and so we use the join method. Join makes the thread behave synchronously, pausing the current thread until the joined thread has finished executing. If thread.alive? returns false, we know that this thread has died. For it to have died it must have completed executing, and for that to have happened it must have been woken up. Thus if the assertion is true, calling 'get' successfully woke up our thread. The same applies for calling get on an empty buffer.
def test_get_waking_up_sleeping_thread
    buffer = SynchronisedBuffer.new(1)
    buffer.put("item 1")
    thread = Thread.new(buffer) { |buffer|
        buffer.put("item 2")
    }
    Thread.pass
    buffer.get
    thread.join
    assert(!thread.alive?)
end

def test_get_waking_up_sleeping_thread
    buffer = SynchronisedBuffer.new(1)
    thread = Thread.new(buffer) { |buffer|
        buffer.get
    }
    Thread.pass
    buffer.put("item 1")
    thread.join
    assert(!thread.alive?)
end

# The results of all our test cases running should look something like the following:
# ![Green is a happy colour](/uploads/2010/07/Screen-shot-2010-07-10-at-12.31.51-AM.png)

# With all these test cases in place, we can be fairly certain that our implementation is correct and the any future bugs that may be introduced will be caught. Note that each test case only makes 1 assertion. While this is not entirely necessary, it is good practice. If a test case fails to pass, then there is no doubt as to which assertion failed. By placing 10 assertions into a test case 'test_buffer' it  becomes much more difficult to find the exact cause of the failure as the name 'test_buffer' failing tells us nothing and what was tested. If multiple assertions are made in the same test case, either one or more of them is redundant, or the test cases should be separated into multiple separate cases. 

# Hopefully these examples give you an understanding of how to use the Ruby Unit Testing Framework, as well as how to test synchronised and multi-threaded classes. As always, please leave a comment or send me an email with any feedback, criticisms, questions or comments.
