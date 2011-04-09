Having now become used to, and in entirely in love with Ruby, I often find myself wishing other languages had blocks. It's such an neat construct that leads to simplistic, elegant, and often more efficient code. During some work on an iPhone app, I had a need to iterate over the objects of a dictionary, getting both key and object for each pair. This is often done with a simple for loop, however the syntax was ugly and, in my opinion, wholly unnecessary:

<pre class='brush:c'>
    NSArray* keys = [data allKeys];
	for (int i = 0; i < objCount; i++) {
		[keys objectAtIndex:i];
		[data objectForKey:[keys objectAtIndex:i]];
		// do something cool, but boy is this a lot of typing..
	}
</pre>

5 lines just to get keys and objects from a dictionary? Crazy! Pining for another way, I delved into the documentation and pulled out this gem of a method - "enumerateKeysAndObjectsUsingBlock".

This does exactly what it sounds, and, oh what joy, it accepts a block. 
</pre><pre class='brush:ruby'>
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // do something cool as we've already got the key and object
        // maybe I'll grab a beer with the time I've saved on typing
	}];
</pre>

The block is declared with a slightly odd, but manageable syntax: ^ (params) { code }
In this case, the params are the key, object, and a boolean called stop. According to the documentation, if we set stop to true, the enumeration will stop, effectively acting as a 'break' function. 

Now that we've got our code looking pretty, how does it match up in performance? Curious, I ran a simple experiment.

<pre class='brush:c'>
    int objCount = 100000;

	NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
	for (int i = 0; i < objCount; i++) {
		[data setObject:@"test" forKey:[NSNumber numberWithInt:i]];
	}

	int iterations = 100;

	NSDate *methodStart = [NSDate date];

	for (int j = 0; j < iterations; j++) {
		NSArray* keys = [data allKeys];
		for (int i = 0; i < objCount; i++) {
			[keys objectAtIndex:i];
			[data objectForKey:[keys objectAtIndex:i]];
		}
	}

	NSDate *methodFinish = [NSDate date];
	NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
	float forTime = executionTime / iterations;
	NSLog(@"Standard For Loop : %f", forTime);




	methodStart = [NSDate date];

	for (int j = 0; j < iterations; j++) {
		[data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

		}];		
	}

	methodFinish = [NSDate date];
	executionTime = [methodFinish timeIntervalSinceDate:methodStart];
	float enumerableTime = executionTime / iterations;
	NSLog(@"Standard Enumerable Loop : %f", enumerableTime);

	NSLog(@"Times Faster : %f", forTime / enumerableTime);
</pre>

Here we're simply creating a dictionary with 100,000 key/value pairs, and iterating over it grabbing both key and value, for the two different methods. To attempt to eliminate any time fluctuations due to unpredictable things like caching or context switching, we're running each loop 100 times. (Note: I tried to run it 1000+ times, but it crashed probably as there are memory leaks galore in the code. Having said that, the memory leaks probably affect the run time as well, but I'll leave that as an exercise for the reader to figure out.)

And the results? Surprising.
</pre><pre class='brush:plain'>
    2011-04-01 18:42:49.163 Standard For Loop : 0.025023
    2011-04-01 18:42:49.616 Standard Enumerable Loop : 0.004506
    2011-04-01 18:42:49.616 Times Faster : 5.553028
</pre>

Using the block is more than 5 (FIVE!) times faster than the ugly, verbose for loop version. I know what I'll be using from now on.
