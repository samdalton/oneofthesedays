Now that you've seen the <a href="http://www.oneofthesedaysblog.com/ruby-day-7-http-protocol/ ">HTTP protocol in action</a>, we can move on to a more advanced version. We will turning the server into a multi-threaded one, allowing it to handle multiple requests simultaneously. Previously, once we had accepted a socket we had to finish processing it until we could accept another one. This meant that if another person tried to connect while it was processing an earlier request, it would have to wait. By sending each request to a separate thread, more than one can be processed at a time resulting in a more responsive server for everyone. 

The approach we will take to implement this is to use so-called <a href="http://en.wikipedia.org/wiki/Circular_buffer">circular buffer</a>. It is essentially a ring with a start and an end. Items go into the end, and come out the front. As we add items, we move the back along to an empty slot. When we take items out, we also move the front along to an empty slot. When the front is the same as the back, we know the buffer is either completely full or completely empty. Lastly, the buffer will have a fixed capacity so that when the front is moved to a position greater than the capacity, it wraps back around and starts from 0.

When we accept a connection the returned socket will be placed into the buffer. A group of threads will continually be checking the buffer for new sockets, and when one is found a thread will take it and process it. This process is useful because it allows us to completely separate our request handling and response generation. We will call these threads 'Worker' threads, and the collection of them will be called a thread pool. Thus, a new request will be placed into the buffer and processed by a worker from the thread pool.

There is a slight caveat to working with threads that use any form of shared data structure (each thread has access to the same circular buffer). A thread can be interrupted at any time by the scheduler and so a number of problems could ensue. For example, let's say we have a method called 'put', which takes a given object and stores it, and then updates the count of the number of stored objects. If the thread is interrupted in between the storing of the object and the updating of the count, the data structure is no longer consistent with itself. If there were no elements added before 'put' was called, the buffer will still say it is empty even though one object has been added. What's worse is that these problems are wholly unpredictable, so we must find a way to ensure these problems can't occur. We need a way of guaranteeing that once 'put' is called, no one else will access the buffer until the method has finished. 

Ruby provides a class called 'Monitor' that will allow us to achieve this by letting us create 'synchronised' blocks of code. A synchronised block is one that can only be accessed by one thread at a time. A thread can get a lock on the method, and no other thread will have access to it until the lock is released. Let's go over the logic we will need to implement for our buffer.

We need to put items in, and get items out. 
The buffer will have a fixed size, and when it is full we should not be able to put anything more in. 
When it is empty, we should not be able to get anything out. 
If we want to get something while it is empty, it should pause until something has been put in, and then return it. 
If we want to put in something while it is full, it should pause until something has been removed.

Let's look at the implementation of this, then go over it.

<pre class='brush:ruby'>
require 'monitor'

class SynchronisedBuffer < Monitor

   def initialize(capacity)
      @capacity = capacity
      @front = 0
      @back = 0
      @elements = Array.new(capacity)  
      @empty_cond = new_cond
      @full_cond = new_cond
      super()
   end

   def get
       synchronize do
           @empty_cond.wait_while {empty?}   
           element = @elements[@front]
           @elements[@front] = nil
           @front = (@front + 1) % @capacity
           @full_cond.signal 
           return element 
        end               
   end

   def put(element)             
       synchronize do
           @full_cond.wait_while {full?} 
           @elements[@back] = element
           @back = (@back + 1) % @capacity           
           @empty_cond.signal    
        end        
   end

   def full?
     synchronize do
       (@front == @back and @elements[@front] != nil)
     end
   end

   def empty?
       synchronize do
           (@front == @back and @elements[@front] == nil)
        end
   end

end
</pre>

We are extending the Monitor class, which gives us access to 'synchronize' and the wait/signal methods. Next, the buffer is initialised
</pre><pre class='brush:ruby'>
def initialize(capacity)
   @capacity = capacity
   @front = 0
   @back = 0
   @elements = Array.new(capacity)  
   @empty_cond = new_cond
   @full_cond = new_cond
   super()
end
</pre>

After setting capacity, front position, back position, and creating a new array to hold our elements, we come to our first bit of the Monitor class. 'new_cond' is a method that returns a ConditionVariable object. This condition variable is an important construct that ensures the code will only execute when the condition is satisfied. We have a condition that elements can't be removed when the buffer is empty (empty_cond) and a condition that we can't add new elements when the buffer is full (full_cond).

<pre class='brush:ruby'>
def get
    synchronize do
        @empty_cond.wait_while {empty?}   
        element = @elements[@front]
        @elements[@front] = nil
        @front = (@front + 1) % @capacity
        @full_cond.signal 
        return element 
     end               
end
</pre>

To have a section of code that is synchronised, we call the 'synchronize' method and have the code inside a do-end block. Once inside, we call the 'wait_while' method on the empty condition. We are passing in the method 'empty?' as our condition, and so the line can be read as 'have any thread that calls this method wait as long as the buffer is empty'. Alternatively, we could write 'wait_unless { !empty? }' which would read 'let any thread call this method unless the buffer is empty, in which case, make them wait'.

When the buffer is empty, any thread that calls get will be put to sleep. If the buffer isn't empty, then the element at the front is removed, and the front position is moved along by 1. The line '@full_cond.signal' will wake up a thread that was put to sleep waiting for the full buffer to have some space. We have just removed an item, therefore there is now space to put in a new item, so we can wake up, or 'signal' a sleeping thread. 

<pre class='brush:ruby'>
def put(element)             
    synchronize do
        @full_cond.wait_while {full?} 
        @elements[@back] = element
        @back = (@back + 1) % @capacity           
        @empty_cond.signal    
     end        
end
</pre>

'put' is the opposite of get. Threads must wait if the buffer is full, and when there is space, an element is placed at the back of the buffer. Once this is done, '@empty_cond.signal' is called and a thread who was put to sleep waiting for the buffer to have some items placed in it, is woken up. As only one thread is woken up at a time, it functions on a first come first served basis.

The final two methods we have already seen used above
<pre class='brush:ruby'>
def full?
  synchronize do
    (@front == @back and @elements[@front] != nil)
  end
end

def empty?
    synchronize do
        (@front == @back and @elements[@front] == nil)	
end
</pre>

If the front is the same position as the back we know that the buffer is either empty or full. We know it will be empty if the element at this position is nil, and full if the element at this position is not nil. These methods must also be synchronised as otherwise they could be interrupted in-between the two conditions, and a corrupted buffer state could result.

Sincere thanks must go to Robert Klemme from the <a href="http://www.ruby-forum.com">Ruby Forum</a> who helped me work out the bugs in this implementation, as well as Craig Taverner from <a href="http://snippets.amanzi.org/2007/07/3-ruby-threads.html">his blog</a> for introducing the monitor class.

So now we have a synchronised buffer which we can fill with incoming requests. What we need next is a thread pool full of workers who are ready to process the contents of the buffer. The class below should look fairly familiar to what was in the <a href="http://www.oneofthesedaysblog.com/ruby-day-7-http-protocol">basic web server</a>, with just a few additions.

<pre class='brush:ruby'>
require 'thread'

class Worker < Thread

    def initialize(buffer)
        super(buffer) { |buffer|
            begin
                loop do
                    socket = buffer.get

                    request = socket.readline

                    validGET = request.match(/GET .* HTTP\/1\.1/)

                    unless (validGET) 
                        socket.puts "HTTP/1.1 400 Bad Request"
                        socket.close
                        next
                    end

                    file = request.split(' ')[1]
                    file = '.' + file

                    unless ( File.exists?(file) ) 
                        socket.puts "HTTP/1.1 404 File Not Found"
                        socket.close
                        next
                    end

                    socket.puts "HTTP/1.1 200 OK\n"
                    socket.puts "Connection: close\n"
                    socket.puts "Content-Type: text/html\n"
                    File.open(file, 'r') { |f| 
                        while (line = f.gets) 
                            socket.puts line
                        end
                    }

                    socket.close
                end
            rescue Exception => e
                $stderr.puts $!.inspect
            end
        }          
    end    
end
</pre>

The main difference is at the top, and the bottom
<pre class='brush:ruby'>
class Worker < Thread

    def initialize(buffer)
        super(buffer) { |buffer|
            begin
                loop do
                    socket = buffer.get
					...
				end
			rescue Exception => e
   				$stderr.puts $!.inspect
			end
		}          
	end    
end
</pre>

Extending the Thread class means we can treat Worker objects exactly as if they were threads. To do this however, we also need to implemenet the initialize method. When creating a regular thread, the instructions to execute are passed to it as a block
<pre class='brush:ruby'>
Thread.new { # do something }
</pre>

Therefore, all we need to do is call 'super', as this will call the initialize method on the parent class, Thread. Placing the block after this will mean that it is executed by the Thread class. We want to pass in the buffer for it to use, so this is passed in as an argument and then into the block.

As each thread will be running outside of the main execution thread, we will not be informed of any errors that occur which can make bug finding difficult. If we wrap the code to be executed in Ruby's equivalent of a try/catch block then we can grab any exceptions thrown and send them to standard error. '$stderr.puts $!.inspect' is a neat shortcut that uses the $! global variable. This contains the most recently thrown exception, and so we are calling inspect on this and sending it to stderr.

Lastly, instead of executing the processing code once, we are looping infinitely. We can to continually check the buffer for new sockets with 'buffer.get'. When the buffer is empty, 'buffer.get' will put the worker to sleep, and it will be woken up eventually when a new socket is placed into the buffer.

Last but not least, we need to create a number of workers, and set up our buffer.

<pre class='brush:ruby'>
server = TCPServer.new('127.0.0.1', '8080')

buffer = SynchronisedBuffer.new(100)

workers = []

for i in (1..40)
   workers[i] = Worker.new(buffer)
   workers[i][:name] = 'worker' + i.to_s  
end

while socket = server.accept
    buffer.put(socket)
end
</pre>

We are creating our buffer with a capacity of 100. This means that we can have 100 requests queued up until we have to start waiting for the buffer to be emptied. We are also creating 40 workers, and naming them so we can tell them apart. Lastly, we have our familiar 'while socket = server.accept' loop but instead of doing any processing, we simply put it into the buffer.

All things going well, your web server should now be capable of handling many simultaneous requests. Leave a comment, email me, send me a tweet or a message on Facebook with any questions, criticisms or comments.
