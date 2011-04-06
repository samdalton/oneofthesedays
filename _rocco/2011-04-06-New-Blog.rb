#### One of These Days, this blog was going to change
# Puns aside, I've now completely switched blogging platforms, migrating off of Wordpress to a custom [Jekyll](https://github.com/mojombo/jekyll) setup.
# While wordpress was a seriously powerful platform, I was only using ~2% of its functionality, and that 2% wasn't doing quite
# what I wanted. Now, with Jekyll, running on Sinatra on Heroku, I can hack things to work as needed. For example, posts
# can be pre-processed with [Docco](http://jashkenas.github.com/docco/) which creates the amazing styling on this page.

# and the amazing styling of source code, like this ->
reasons.each do |reason|
    puts reason.explain
end

# I figured it was worth the switch just for this alone, as most of the time I'm talking about code.
# I'm also hoping that the easiser method of posting (git push heroku master) will encourage me to write more frequently, so stay tuned!
#
# (I will be gradually migrating posts from the old blog over to here, which hopefully won't take too long)
