# I live in a flat with 2 other avid internet users. Some months our bandwidth gets used up within a week yet my computer tells me I've only used a few hundred megabytes. In order to get accurate accountability for my internet usage, in comparrison to my flatmates, I wrote a PHP script to give me my usage as a percentage of the total usage for each day.

# Our ISP provides a web portal which gives statistics such as daily and monthly usage. To get the statistics from my own usage, I installed [vnstat](http://humdi.net/vnstat/).

# Two combine the 2 I decided I would use PHP as an excuse to try out the Zend_Http_Client component. 

# First off I needed to grab the stats from my computer. This is quite straightforward with the system() function.
ob_start();
system('vnstat -d -s');
$vnstat = ob_get_contents();
ob_end_clean();

# Output buffering is used to capture the information that the system command normally sends to the browser. As the system command only returns the last line of output from the command, we can get the entire output by using ob_get_contents().

# The options for vnstat make it return statistics for just today (-d) and in short form (-s), looking like this
          rx       /         tx      /        total    /  estimated
 wlan0:
           yesterday    162.76 MB  /   78.25 MB  /  241.00 MB
         today    138.14 MB  /   89.97 MB  /  228.11 MB  /     523 MB

# Now we need to get just the total for today:
# make an array of the output
$vnstatComponents = split("/", $vnstat);
# get today's usage (2nd to last element of the array) and remove whitespace
$netUsage = trim($vnstatComponents[count($vnstatComponents) - 2]);
# remove 'MB', giving us just the number
$myUsage = substr($netUsage, 0, strlen($netUsage) - 3);

# We're now ready to start using Zend_Http_Client. 
# open a link to isp website
$client = new Zend_Http_Client("https:// the.vodafone.co.nz/acnts/myaccounts.pl/login");
$client->setMethod(Zend_Http_Client::POST);
$client->setParameterPost(array(
    'login'  => 'myusername',
    'password' => 'mypassword'
));
$response = $client->request();

# grab our cookies
$cookiejar = Zend_Http_CookieJar::fromResponse($response, $client->getUri());

# The link we open a connection to is the link that the login form will submit to. Firebug can be handy to quickly find this out. You'll also need to set the array keys in the setParameterPost method to match the names of the username and password fields on the login form.

# The last part of the code is what will enable us to persist our login credentials. Zend_Http_CookieJar is fairly self explanatory in it's name. We pass in the request object and the uri of the site we're posting to and it will store the cookies that the browser would receive if we were actually visiting the site.

# Now let's try and log in to the usage page with our new cookies.
# if we're logged in ok, open account page
if ($response->getMessage() == "OK") {
	$client = new Zend_Http_Client("https:# the.vodafone.co.nz/acnts/myaccount-int.pl/usage-data");
	$client->setCookieJar($cookiejar);
	$usageResponse = $client->request();	
}

# And that's it! We've now got an object that contains the entire content for the page we specified in the Zend_Http_Client constructor. Now this data might be a little unwieldy to dissect so we can use another handy Zend component, Zend_Dom_Query.
$dom = new Zend_Dom_Query($usageResponse->getBody());
# If you have any experience with CSS then the usage of this object for getting data will seem quite natural.

$dom->query('.tdDataRight');

# This will return an array of all elements with the class 'tdDataRight'. 

# While this example is rather specific, it shows how to use Zend_Http_Client in a way that will no doubt apply to many other situations.
