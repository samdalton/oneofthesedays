# While high speed internet is gradually working its way into most homes, it's not absolutely everywhere, and when it is, your ISP may be limiting speeds during certain times of the day or for certain types of internet traffic. To make things easier on users, we can have our web servers compress the data they send. Instead of sending a 200kb Javascript file, it can first be compressed on the server to ~50kb, sent via TCP, and then uncompressed by the web browser. The amount of data being sent is 1/4 of the size, and so the total time is reduced significantly (time taken to compress and uncompress is considered negligible). 

# Unfortunately, my attempts to wrangle <a href="http://ruby-doc.org/core/classes/Zlib.html" title="Module: Zlib">Ruby's Zlib compression library</a> have not been successful. The documentation is patchy, at best, with comments such as "???", "TODO: better comments", and the occasional snippet of Japanese. Given today's time constraints, I'm shipping an example that I feel should work, but does not. I will work on resolving the issue, and update this post when it works.

socket.puts "HTTP/1.1 200 OK\n"
socket.puts "Connection: close\n"
socket.puts "Content-Type: application/gzip\n"

File.open(file, 'r') { |f|  
    gz = Zlib::GzipWriter.new(socket, Zlib::BEST_COMPRESSION, Zlib::FINISH)  
    while (line = f.gets) 
        gz < < line
    end
    gz.close
}

# I have modified the header to say we are sending the browser compressed data, and created a new Gzip writer object inside the response loop which spits out the contents of the requested file into the gzip writer, which has been given the socket. The documentation states that Gzipwriter can take an IO object, which socket happens to be, however when it runs an exception is thrown saying that the IO file has been closed. While possibly something simple, the answer has thus far eluded me. 

# If you have any suggestions or solutions, leave a comment or send a tweet/email. Stay tuned for updates.</pre>
