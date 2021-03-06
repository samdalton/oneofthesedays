# The importance of <a href='http://ruby-doc.org/core/classes/File.html'>files</a> goes without saying, so let's get straight into it.

# <h2>Creating a File</h2>
# This command will first look for a file in the current directory called myFile, creating it if it can't be found. The 'w' tells ruby that we want to write to it. We can then write to the file by using the 'write' method.
myFile = File.open('myFile', 'w')
myFile.write('my awesome story')
myFile.close

# When a file is opened the operating system records which program opened it. If we don't tell the operating system that we have finished with the file, it will keep this information until the program exits. While this may not cause a problem in a simple example, it could lead to errors with a large number of files, or multiple programs accessing the same file. Calling 'close' on the file will take care of this. Whenever you open a file, you must close it when you are finished.

# You can probably guess how to read from the file
myFile = File.open('myFile', 'r')
puts myFile.read
myFile.close# my awesome story

# Identical to the first example, but instead of a 'w' for writing to the file, we use an 'r' for reading from the file. The letter 'a' can be used if we want to open a file, and append content to the end of it.

# <h2>Reading From a File</h2>
# For those of you coming from a PHP background, this code below should look familiar
$fp = fopen('myFile', 'r');
while (!eof($fp))
	fread($fp)
fclose($fp)

# which simply opens a file and reads each line of it until it reaches the end. This is rather ugly, to be honest. We have to create a file pointer, check that we haven't reached the end, read from it, and then close it. That's 4 Steps, but we can do it in just 1 line in Ruby.
File.open('myFile', 'r') { |f| f.read }
# By placing a block at the end, we can catch the opened file, and loop over each line in the file. When the block ends, Ruby will automatically close the file for us. The block method of file handling is preferred as you won't run the risk of forgetting to close a file.

# <h3>Peculiarities</h3>
# If you try writing a new line to a file with the typical \n character, you may find that it does not work.
File.open('test', 'w') { |f| f.write('line 1 \n line 2') }
File.open('test', 'r') { |f| puts f.read }# line 1 \n line 2
# The \n character is stored as a \ character followed by the letter n. Not quite what we wanted. So how can you create a new line in your file? If we use 'puts' instead of 'write', then Ruby will automatically place a real newline character at the end, once for each time we call puts.
File.open('test', 'w') do |f|
    f.puts('line 1')
    f.puts('line 2')
end
File.open('test', 'r') { |f| puts f.read }
# line 1
# line 2
# The file clearly has 'line 1' and 'line 2' on separate lines so we have succeeded.

# <h2>File Methods</h2>
# If you are familiar with UNIX, bash in particular, then you will feel right at home with the File class. It offers just about every bash file operation, calling them by the same names and accepting the same arguments. For example, you can use 'chmod' and 'chown' to change permissions, or set who owns the file. Copy, move, delete, rename, stat, and more, are all available. Have a look at this <a href='http://www.doc.ic.ac.uk/~wjk/UnixIntro/Lecture2.html'>UNIX tutorial</a> if you want to learn about file operations. 

# <h2>End</h2>
# Hopefully you now have some familiarity with the way Ruby handles files.

# <strong>Update</strong>
# <em>I clearly was not familiar enough with blocks at the time of writing this post, as David pointed out in the comments. I had an incorrect statement stating that a file handler passed into a block can only be used once. The post has been updated to reflect this.</em>
