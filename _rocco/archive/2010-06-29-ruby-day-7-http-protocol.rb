# We have created a simple server that responds with whatever text it received when we connect to it via TELNET. The uses for this are limited and so we want now to begin implementing the <a href="http://www.w3.org/Protocols/" title="HTTP - Hypertext Transfer Protocol Overview">HyperText Transfer Protocol (HTTP)</a> to enable us to show a web page. Being a standard, and universally adopted protocol, a web browser knows that if it uses HTTP to talk to a web server, they will both understand each other. HTTP defines a set of actions that a web server must carry out. These are:

# <ul>
	# <li><strong>OPTIONS</strong> - Returns information and options available for the server, or a specified resource. 'OPTIONS *' will tell you what the entire server is capable of, whereas 'OPTIONS filename' will tell you what it can do with that particular file.</li>
	# <li><strong>GET</strong> - Returns the contents of the specified file or directory. 'GET index.html' will return the file index.html. The GET method is what we will be implementing.</li>
	# <li><strong>HEAD</strong> - Works the same as GET, except the contents of the file or directory is not returned. Instead, meta-information is returned, such as the file-type or when it was last modified.</li>
	# <li><strong>POST</strong> - Sending information along with a POST request will associate with the specified file. 'POST index.php?foo=bar' will send the value 'bar' to the file 'index.php', storing it under the name 'foo.'</li>
	# <li><strong>PUT</strong> - PUT is the opposite of GET: it sends a file and a location, and the server will store that file in that location.</li>
	# <li><strong>DELETE</strong> - You can remove a specified file with 'DELTE filename', however there is no guarantee that the server will actually do this.</li>
	# <li><strong>TRACE</strong> - Lists the exact servers a request must go through to reach the destination server. This may be a proxy server, for example.</li>
	# <li><strong>CONNECT</strong> - Not used in HTTP 1.1, CONNECT is reserved for future implementations that may wish to set up some form of secure communication.</li>
# </ul>
# (Paraphrased and adapted from <a href="http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html" title="HTTP/1.1: Method Definitions">W3C</a>)

# For a basic web server we will only need to implement the GET method, as that will at least allow us to send content to the browser. We'll also want to send back a few status codes. Status codes let the browser determine what the server has done. The most prevalent example is 404 - File Not Found. Equally as important is 200 - OK, which is returned when the server can successfully carry out the request. Along with these 2, we will send back 400 - Bad Request if something other than a GET request is sent. The entire server code is below, and each step is explained in detail afterwards.

require 'socket'

# The first 3 lines should look familiar.
# We're setting the program to listen on TCP port 8080, and once a connection is made, we're storing the received information in the 'request' variable.
server = TCPServer.new('127.0.0.1', '8080')

while socket = server.accept
    request = socket.readline

    # After this we're checking if the request is a valid HTTP 1.1 GET request.
# We are using the regular expression '/GET .* HTTP\/1\.1/' to check if the request fits the format 'GET file HTTP/1.1'. '.*' represents any sequence of characters, of any length. While this isn't perfect, it should suffice for now.
validGET = request.match(/GET .* HTTP\/1\.1/)

# 'unless' functions identically to 'if not', so the code inside will only be executed if validGET is not equal to something other than nil. validGET will be nil if the request string did not match the regular expression. Hence, if the request doesn't match we are sending back 'HTTP/1.1 400 Bad Request', and closing the socket. 'next' stops Ruby from executing the remaining contents of the loop, and forces it to start the loop again.
    unless (validGET) 
        socket.puts "HTTP/1.1 400 Bad Request"
        socket.close
        next
    end

# Here we are simply finding the name of the file they requested the server to load. The GET request consists of 3 parts, with a space in between each: 'GET' 'filename' 'HTTP/1.1'. Thus, the second element in the array returned by split will be the filename. We prepend the filename with a '.' to ensure that the resulting file path is relative to the current directory. If they request index.html, the request will come through as /index.html. By prepending '.' the file becomes ./index.html which is relative to the current directory.
    file = request.split(' ')[1]
    file = '.' + file

# Just as we checked for a correct GET request, we need to check if the requested file can actually be sent. File.exists? will return true if the given file exists on the computer. If not, we send back the famous 404 error.
    unless ( File.exists?(file) ) 
        socket.puts "HTTP/1.1 404 File Not Found"
        socket.close
        next
    end

# Having got to this point in the code, we can say that we have received a correctly formed request for a file that we are able to send back. What we do next is part of the HTTP protocol, and is us telling the client that the request can indeed be processed. This is the 200 OK response. Following this, we send a 'Connection: close' to indicate that we have finished sending back this message. 'Content-Type: text/html' is the beginning of a new message, and it is telling the client that they can expect to receive an html file. If we want our web server to handle images, and other file types, we will have to add in logic to send back the correct content type. Today we will just stick with text/html.
    socket.puts "HTTP/1.1 200 OK\n"
    socket.puts "Connection: close\n"
    socket.puts "Content-Type: text/html\n"
# Finally, we can send the contents of the html to the client. We simply open up the requested file and loop over each line in it. For each line, we send it back through the socket.
    File.open(file, 'r') { |f| 
        while (line = f.gets) 
            socket.puts line
        end
    }

    socket.close
end

# To test the server, create an html file called test.html in the same directory as the Ruby file containing the above code. Run the program, and point your browser to 'http://127.0.0.1:8080/test.html'. Hopefully you should see the contents of the html file rendered by the browser.

# There you have it. A web server that handles HTTP 1.1 GET requests to successfully send back an HTML file, while also handling malformed requests, and requests for non-existent files. Granted, there is a large amount of functionality that we didn't implement, including some important error checking, but hopefully it highlights the overall mechanisms of HTTP and web servers.
