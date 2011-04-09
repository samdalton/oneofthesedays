[caption id="" align="alignright" width="234" caption="&#039;The Women&#039;s Army Corps: A Commemoration of World War II Service&#039;&#039; By Judith A. Bellafaire. CMH Publication 72-15"]<img alt="" src="http://upload.wikimedia.org/wikipedia/commons/8/89/WACsOperateTeletype.jpg" title="Teletypewriter" width="234" height="224" />[/caption]
I left the 30 day to Ruby series with a rather abrupt and unfinished ending. This post is the next in the hopeful continuation and completion of the series.

Without further ado then, Input/Output (IO)! For any operations involving sending or receiving data (be it to a file, or another computer), you're going to need some way of telling the operating system what to do. Any modern OS has a set of system calls that are used to interact with the computer's hardware, while ensuring nothing untoward happens to it. For writing to a file, we might call fwrite in the C standard library. By passing in a file name and some data, the library will instruct the OS to put the given data in the given file. We can also instruct the OS to send and receive data to things other than files however, a process, for example.

Let's look at an example to make the explanations easier.
<pre class='brush:ruby'>
puts IO.popen('date).read
Sat Jan 22 22:01:35 NZDT 2011
</pre>

We can see that the output of the above line was today's date and time, exactly as if we were to open the terminal and type in the UNIX 'date' command. Note that we are calling the read command on the object we've created, exactly as if we were reading from a file. What's going on here? popen, or process open, is a function in the Ruby IO library that instructs the OS to fire up a process with the given command (date, in this case). A process is similar to a file in that it can receive inputs and produce outputs, and so Ruby ensures theses two ends are available for use, just as if a file had been opened. The advantage of the IO library is that the API is fixed for whatever IO object you're actually using. Be it a process, file, socket, pipe et al, the commands required for sending/receiving data are always the same. It can be seen then that after popen runs the date command, we are simply reading the output of this command, retrieving today's date.

Let's take another example, but to do so we must install a rather neat program called <a href="https://github.com/drewcrawford/Phone-Pipe">phonepipe</a>. You could run a similar example without this, a notifo account and a smart phone with push capabilities, but it's rather satisfying to do it this way. Keep reading once you've got it set up and working.

What we want to do is have Ruby send some text to our phone. A simple solution would be to simply have Ruby call 'echo hello | phone', which can be achieved using the shorthand %x syntax:
<pre class='brush:ruby'>
%x{ echo hello | phone} 
</pre> 
This simply has Ruby drop out the commands contained into a shell, causing the word hello to be sent to your phone. This doesn't fit nicely with our IO examples however so let's try something else.

<pre class='brush:ruby'>
IO.popen('phone', 'w') do |f|
    f.puts 'Hello from process ' + Process.pid.to_s
end
</pre>

Just as we opened up a process for date, we're opening up a process for the phone command. The difference is that we're specifying that we want to be able to write to it, just as we would write to a file. By passing it a block, we can do things with the returned process handle. Inside the block, we're simply using puts to send our message to the phone process. You should see a message along the lines of "Hello from process ----" appear on your phone, where ---- is any number. While this is purely a contrived example, you can see just how easy it is to read and write to processes in Ruby. To show the flexibility of these, take a look at this example which opens up an interactive Ruby prompt inside the process and has it execute Ruby code:
<pre class='brush:ruby'>
IO.popen('irb', 'w') do |f|
   f.puts "puts 'hello'"
end
</pre>
We're opening an irb process, and feeding it "puts 'hello'" which gets run by irb and executed. <br /><em>Note: if someone can turn this into a <a href="http://en.wikipedia.org/wiki/Quine_(computing)" title="Quine (computing) - Wikipedia, the free encyclopedia">quine</a>, it would be awesome to see in the comments! Here's a start:</em>
<pre class='brush:ruby'>
IO.popen('irb', 'w') do |f|
   f.puts " IO.popen('irb', 'w') do |f|
       f.puts \"puts 'hello'\"
    end"
end
</pre>

Hopefully this brief foray into the world of Ruby::IO has piqued your interested, but before I TTYL we must look at the TTY. In times past, there was the Teletypewriter (TTY): A magical device that would take digital input and type output onto physical paper via a typewriter. This name, tty, has stuck around in UNIX, such that any terminal window you open is named something along the lines of ttyn where n is the index nth terminal window you've opened (the first window would be tty0, and so on). While nothing to do with typewriters, the idea of printing text to a screen is somewhat similar to this, so if you don't think about it too much it makes sense. On a typical OSX or Linux system, the tty interfaces appear as simple files on the filesystem, allowing us to read and write to them. I happen to be running OSX, and I know that the first tty lives at /dev/ttys001, so if I open this up and write to it, the data will be displayed on the first terminal window I have open. 
<pre class='brush:ruby'>
File.open("/dev/ttys001", 'w') do |f|
    f.puts 'Hello from Ruby!'
end
</pre>
We're using the File class in this case, not IO, to open up the tty file, but everything functions identically. If you have a terminal window up, you can check it's tty file by viewing the terminal window's properties. If it is indeed ttys001, you should see 'Hello from Ruby!' appear on it. If it's something else, replace the file name and similar results should occur.

This is all well and good, but what can you do with it? Well, here's a feeble attempt and what could be the beginnings of a game of pong:
<pre class='brush:ruby'>
width = 80
height = 20

length = 160
fps = 30

File.open("/dev/ttys001", 'w') do |f|
   row = 0
   increment = 1
   (1..length).each do |i|
      sleep(1.to_f/fps)
      f.puts "\e[2J\e[f" # clear screen character
      f.puts  "" + ("\n" * row) + (" " * (i % width)) + "o"
      
      row += increment
      if row > height
          increment = -1
      elsif row < 1 
          increment = 1
      end
   end
end
</pre>

That's all for now, but give it a whirl, and be sure to post any cool uses/examples you have in the comments!</pre>
