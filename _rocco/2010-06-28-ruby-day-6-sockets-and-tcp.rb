To kick off this web-server series we'll create a server which, at it's simplest, consists of just 3 lines of Ruby code. It can be called an echo server, and it does just that; it sends back to you whatever you send to it. Find a large, empty room, yell out "Ruby is awesome" and you'll hear it repeated (this also works in a small room filled with Ruby developers). If you're not fond of going outside (or socialising) however, you can use an echo server to achieve the same effect. Send the text "Ruby is awesome" to this echo server, and it will reply with the same message.

This simple example expresses a concept that is fundamental to how any server works. They listen for requests, do something, and (sometimes) send something back. A web server is listening to requests to load a particular page, and in response, it sends back the contents of that page. A mail server listens for requests to download mail messages, and in response it sends the latest emails. As most servers follow this basic pattern, standards have been developed and adopted that describe in what format the requests and responses should be. Warning: You are now entering the world of acronyms.

TCP, UDP, HTTP, STMP, NTS, FTP, ARP, SSH, IMAP, DNS, DHCP, IRC, to name but a few, are all protocols that describe requests and responses. Today we will be using the Transmission Control Protocol (TCP) to implement our simple echo server. To describe TCP, we can look at it's simpler cousin: the Universal Datagram Packet (UDP). UDP is a protocol that specifies how data should be broken up into chunks, in order to send over a network. It also specifies how that data knows where it has to go. By pairing up a packet with an Internet Protocol (IP) address, network hardware will (all things going well) be able to send a packet it receives to the correct destination. The packet also contains the IP address of the sending machine, so that the receiver knows where to send its response. TCP does exactly what UDP does, except it does a few extra things to ensure that packets sent do actually arrive correctly. This includes error checking and correction, as well as ensuring that the sender isn't sending more packets that the receiver can handle at once. 

If we want to create an 'echo' server, we will need to listen for packets that are sent to us via the TCP protocol. When we receive one, we need to extract the message, and send it back again. Here's the server:

<pre class='brush:ruby'>
require 'socket'

server = TCPServer.new('127.0.0.1', '8080')
socket = server.accept
socket.puts socket.readline
</pre>

Firstly, we're creating a new TCPServer object that will listen for requests at the IP address 127.0.0.1 and on port 8080. 127.0.0.1 is an IP address reserved to represent the local machine. If the operating system is asked to send a packet to this address, it realises that this is actually the same machine and so it is a good way of testing without requiring 2 computers. Port 8080 is a common port used for alternative web servers, which we will be creating eventually, so we may as well use it now. As the network card receives packets for the entire operating system, and not specific programs (mail client, chat client, etc.), a program must associate itself with a port number. The operating system can then look at the port number in the received packet and determine which program it should go to. Packets with port number 21 will be sent to your FTP client, port 110 packets will go to your mail client. We want packets with port 8080 to be sent to our Ruby program. To ensure there is no confusion, only one program can take one port number at a time, so if you receive an error about port 8080 being use, you may have another program already attached to it.

When you run this program, nothing will happen. The program will continue running forever and nothing will be displayed to the screen. Why doesn't the program end? The answer is in the second line, server.accept. Accept is a method which causes the program to pause until the TCPServer object receives a packet. As soon as it does, it returns a Socket object which contains the received packet and information on the machine who sent it. This socket acts as our end of the connection created between us and them, <a href='http://www.youtube.com/watch?v=f99PcP0aFNE'>a tube of the internet</a>, if you will allow the analogy. Whatever is sent down this tube, we will eventually receive, and vice versa. Therefore, to create our echo, we come to the third line. 
<pre class='brush:ruby'>
socket.puts socket.readline
</pre>
We read the socket, which will contain the message they sent, and we use 'puts' to sent it straight back. To see this in action, we can use telnet to connect to our running server and send it a message.
<pre class='brush:ruby'>
telnet 127.0.0.1 8080
</pre>
The screencast below will show it working.

<object width="600" height="450"><param name="allowfullscreen" value="true" /><param name="allowscriptaccess" value="always" /><param name="movie" value="http://vimeo.com/moogaloop.swf?clip_id=12910541&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=00ADEF&amp;fullscreen=1" /><embed src="http://vimeo.com/moogaloop.swf?clip_id=12910541&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=00ADEF&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="600" height="450"></embed></object><p><a href="http://vimeo.com/12910541">A Simple TCP Echo Server in Ruby</a> from <a href="http://vimeo.com/user4148440">Sam Dalton</a> on <a href="http://vimeo.com">Vimeo</a>.</p>

Voila! Hopefully you managed to get it working, and understood why it works as well. While this is a server in just 3 lines, it's not particularly useful. Once someone connects, the programs ends and the server closes. To make it run indefinitely we will need some kind of infinite loop.
<pre class='brush:ruby'>
while socket = server.accept
    socket.puts socket.readline
    socket.close
end
</pre>
In Ruby, every operation returns something, even variable assignment. The returned value will be equal to whatever value was set. So in this case, when server.accept detects a connection and returns a socket object, the while loop will see that an object was returned. An object is not regarded as false, and so the loops is entered. When the loop ends, server.accept is called once more, and the process repeats indefinitely. The program will never end because server.accept will always wait until it gets a connection, and hence will always return a non-nil value to the while loop condition. Just as with files, we also have to close the socket. We didn't do this in the first example because the program exited straight afterwards so there wasn't much need. 

So there you have it, a 3 (or 4) line echo server that uses the TCP protocol.
