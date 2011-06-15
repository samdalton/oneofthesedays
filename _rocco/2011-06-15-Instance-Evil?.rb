# Some playing with dynamic methods in a Ruby class led me into an interesting problem. 'instance_eval' was being used to allow for dynamic getting and setting of various attributes. This worked great, until the objects needed to be cached in Rails. 
# An error was being thrown, "TypeError: singleton can't be dumped", which didn't make immediate sense. Some digging and playing however led to the answer that Marshal cannot serialize objects that have had instance_eval used on them, which is probably 
# fair enough as Marshall would have no way of knowing how to redo the eval when the object is loaded back again. 

# We can add an instance_eval block to add in an instance method, to demonstrate.
class A
  def initialize
    self.instance_eval do
      def unleash(what = nil)
         puts what 
      end
    end
  end
end

a = A.new
a.unleash("the hounds") # the hounds

# However, we are not able to serialize the object ):
puts Marshal::dump(a) #> TypeError: singleton can't be dumped


# The solution was to use the magical method_missing; we get the same result, but we're also able to serialize the object.
class A
  def method_missing(m, *args, &block)
    puts "#{m}(#{args})"
  end  
end

a = A.new

a.unleash # unleash([])

a.unleash = 'the hounds' # unleash=(["the hounds"])

puts Marshal::dump(a) # o:A

# Happily marshaled (:

# _(Reverse smilies inspired from [Frank Chimero](http://blog.frankchimero.com/post/6358013062/ten-more-things))_
