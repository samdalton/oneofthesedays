Today we will take a brief look at Ruby's <a href="http://ruby-doc.org/core/classes/URI.html" title="Module: URI">Uniform Resource Identifier (URI) class</a> in order to handle a wider range of requests in our web server. Currently, if we enter a URL such as 'http://localhost:8080/test.html' into our web browser we will receive a request that looks like 'GET /index.html HTTP/1.1'. If we want to send any extra parameters such as an id (http://localhost:8080/test.html?id=123) then our server will naively assume that the file we are requesting is named 'index.html?id=123', and so it will not be able to find it.

By treating the request as an <a href="http://www.bernzilla.com/item.php?id=100">HTTP URI</a>, we can interpret the request more intelligently, separating it into the filename and the query parameters. 

We can modify our worker class like so
<pre class='brush:ruby'>
file = request.split(' ')[1]
file = '.' + file

uri =  URI.split(file)
file = uri[5]
query = uri[7]
</pre>

The 'split' method will take a URL and split it up into 9 components which will be explained by using the URL 'http://www.google.com/index.html?user=123' as an example

<pre class='brush:ruby'>
Scheme - http
Userinfo - nil
Host - www.google.com
Port - 80
Registry - nil
Path - /index.html
Opaque - nil
Query = user=123
Fragment - nil
</pre>

(Userinfo, registry, opaque and fragment are not likely to be used for an HTTP request so we can ignore them.)

The two components we are interested in are path and query, elements 5 and 7 respectively. By passing the middle part of our GET request to the split method, we can grab the 2 elements we need. 'uri[5]' contains the file we want, so that will be passed to the File class. 'uri[7]' contains the query parameters which can be dealt with later on.
