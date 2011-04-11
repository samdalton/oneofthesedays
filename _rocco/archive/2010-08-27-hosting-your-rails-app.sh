# So you've got this sweet rails app made, and it runs fine locally, but you'd like other people to be able to use it, right? For that, you can sign up for an account with a web hosting company, but with so many, how do you choose one?

# So far, I've used 2 different companies to host a rails app, <a href="http://www.rackspace.com/index.php" title="Dedicated Server, Managed Hosting, Web Hosting by Rackspace Hosting">Rackspace</a> and <a href="http://heroku.com/" title="Heroku | Ruby Cloud Platform as a Service">Heroku</a>. I've settled with Heroku, and couldn't be happier.

# ![Rackspace](/uploads/2010/08/Dedicated-Server-Managed-Hosting-Web-Hosting-from-Rackspace.png)

# What they offer is essentially a Virtual Private Server (VPS) solution, along with your run of the mill cloud storage, much like Amazon's ubiquitous S3. Having an entirely blank server that you can install any OS and software on is a real charm. Instead of having too little control, you have too much control. If you're a sysadmin geek or bash guru, you will have a blast, making this a service that probably wouldn't suit someone with limited server experience.

# I installed a typical LAMP stack, with Ubuntu 8.x as my distribution of choice. There really was no difference from setting up this server than if I were doing it on a local development machine, with the exception of DNS. Alongside setting up your /etc/hosts file, you will need to use a simple control panel to add in your domain.

# This excess of freedom however does create a large amount of setup work to get your server running, especially when it comes to getting rails going. Following <a href="http://hackd.thrivesmarthq.com/how-to-setup-a-linux-server-for-ruby-on-rails-with-github-and-phusion-passenger" title="How-To Setup a Linux Server for Ruby on Rails - with Phusion Passenger and GitHub - Hack'd">this tutorial</a> on setting up Passenger and Capistrano, it took around 30 minutes and a couple of headaches.

# One downside with Rackspace is that it is down to the administrator of the account to ensure the server is secure. For an experience sysadmin this is probably a non-issue, but for those competent enough to get a server running but lacking any solid security experience, it can be a tad dangerous.

# To sum up, if you're looking for complete control, extremely reasonable pricing, on demand support, and don't mind getting your hands dirty in the command line, then you will probably love Rackspace.

# ![Heroku <3](/uploads/2010/08/heroku-logo_big.png)

# If you then navigate to the URL it gives you, you will see your rails app. The only caveat to this is that you must be in the root directory of your app, and it must be in a git repository. If you're starting a brand new rails app, the setup would look like this:
heroku create MyAwesomeRailsApp
git push heroku 

# This will then have your new rails app running at http://skynet.heroku.com. 
rails Skynet
cd Skynet
git init
git add .
git commit -m "Importing Skynet"
heroku create skynet
git push heroku 


# Heroku also comes with a swathe of plugins. From hosted MongoDB installations, to effortless DNS, to Cron jobs and auto backups, it's like a Sith lord having the keys to the Padawan training room, and all the Jedis are away on holiday.

# Essentially, Heroku has done to hosting what rails did for web development. Convention over configuration, excellent user experience, and having everything "just work" with the minimum amount of effort.

# Another neat thing with Heroku is that all of the commands and tools it provides are accessible through a command line tool. You can add domain names, add more concurrency to your app, run rake commands, and just about every other feature they provide.

# So if you're looking for a no fuss, beautifully designed, effortless workflow, rubyesque, affordable and scalable solution, you might want to check out Heroku. (However, it's built on Rails, which <a href="http://canrailsscale.com/" title="Can Rails Scale?">can't actually scale</a>, so you may want to take that into consideration.)
