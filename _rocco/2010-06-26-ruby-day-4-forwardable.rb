Today's topic is a favourite of upper management: delegation. Delegation is when you make someone else do something for you, but you still get the credit for it. The <a href='http://ruby-doc.org/core/classes/Forwardable.html'>Forwardable</a> class in Ruby does much the same thing. It lets an object call methods on another object, but appearing to the user like the first object is actually doing the work. To see the advantage of forwardable, we can look at an example where it's not used. We will create two classes, one called MarsExplorer and a second called MissionControl. We want to be able to control the mars robot in a more suitable, oxygen filled environment, which would be Mission Control.

<pre class='brush:ruby'>
class   MarsExplorer

   def forward
       @speed = 1
       puts @speed
   end 

   def backwards
       @speed = -1
       puts @speed
   end

   def stop
       @speed = 0
       puts @speed
   end
end
</pre>

Our robot can move forwards, backwards, and it can stop. After each action we ask it to print out the speed, so we can keep track of when the methods are called.

<pre class='brush:ruby'>
class MissionControl

    def initialize
        @robot = MarsExplorer.new
    end

    def forward
        @robot.forward
    end 

    def backwards
        @robot.backwards
    end

    def stop
        @robot.stop
    end

end
</pre>

Phew, that was a lot of typing! Too much, in my opinion. For each method in MarsExplorer, we have had to write the same method definition in MissionControl. If we ever change our robot class to have a turn method, or we change 'stop' to 'brake', then we will have quite a few changes to make in our MissionControl class. In addition, MissionControl is now very cluttered with method definitions that aren't directly related to the class. It would be better if we could simply let MissionControl respond to the methods of MarsExplorer, in a simple and unobtrusive way. We can achieve this by using Forwardable, as you can see in our updated MissionControl.

<pre class='brush:ruby'>
require 'forwardable'

class MissionControl
    extend Forwardable

    def_delegators :@robot, :forward, :backwards, :stop
    def_delegator :@robot, :stop, :brake

    def initialize
        @robot = MarsExplorer.new
    end      
end
</pre>

Notice that all of the method definitions are gone, with the exception of initialize, which hasn't changed. Firstly, we have said that we want to make MissionControl extend Forwardable
<pre class='brush:ruby'>
extend Forwardable
</pre>
This gives us access to the methods in Forwardable that follow, def_delegators and def_delegator. When we want to provide access to multiple methods, and we don't mind calling them by the same name, we can use def_delegators. The syntax is explained below.
<pre class='brush:ruby'>
  def_delegators :@robot, :forward, :backwards, :stop
# def_delegators :theObject, :method1, :method2, :method3
</pre>
We are saying that MissionControl should respond to the methods forward, backwards, and stop, and it should respond by calling the method of the same name on the robot object. Instead of 3 method definitions, we only need one line stating which object to delegate to, and what methods it should allow delegation of. If we want to change the apparent name of the method, we can use def_delegator.
<pre class='brush:ruby'>
  def_delegator :@robot, :stop, :brake
# def_delegator :@theObject, :methodName, :desiredMethodName 	
</pre>
Now we can call the method 'brake' from MissionControl which will call the 'stop' method on our MarsExplorer. Neat! Let's take it for a spin.
<pre class='brush:ruby'>
control = MissionControl.new
control.forward
#=> 1
control.backwards
#=> -1
control.stop
#=> 0
control.brake
#=> 0
</pre>

Now, not all of us are engineers at NASA, so where might you use Forwardable in a real life? It is useful anywhere you find yourself writing methods similar to the ones in the first MissionControl implementation, simple wrapping of another object's methods. It can also be used as a form of adapter. By defining your own class that delegates to another object, and only calling the methods on this class, the delegate object can be set to anything. For example, if you are writing an application that will be using a database, but you're not sure if it will be MySQL, MSSQL, or PostgreSQL, you can create a wrapper class that has def_delegator set for each method you want to be able to call. Your implementation will use this wrapper class for all database access, with the method calls being delegated to whichever object you have set. If the underlying database object has different method names, you only need to update your def_delegator definitions, and all of your implementation code will remain the same. Here's a contrived example to demonstrate this.

<pre class='brush:ruby'>
class MyDatabase
	extend Forwardabble
	
	def_delegator :@db, :newMySQL, :new
	
	def initialize
		@db = MySQL.new
	end
end	

db = MyDatabase.new
db.new
</pre>
Suppose that there exists a 'MySQL' class, which provides the method 'newMySQL' to create a new database. If we build our implementation on the MyDatabase class instead of the MySQL class, we will be able to switch to PostgreSQL in the future by simply changing the def_delegator
<pre class='brush:ruby'>
def_delegator :@db :newPostgreSQL, :new
</pre>
Our implementation code remains untouched, and we have only made one small change. While this example is entirely fictional, it shows how you can create a level of abstraction with Forwardable.
