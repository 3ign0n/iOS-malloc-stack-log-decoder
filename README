What is this?
-------------------------
A ruby script to decode iOS malloc stack log


# How does this work?
To take a quick look, just type:

    ruby iOS-malloc-stack-log-decoder stack-logs.PID.AppName.sample.index


The reason I need this
-------------------------
I'm struggling with an EXC_BAD_ACCESS issue on iOS devices now.
It doesn't occur on a simulator. Too bad!!!
It's extremely hard to debug such a case, because XCode has poor tools to debug on devices.

Of course, I already tried XCode static analyze and one of instruments, Leaks,
however they didn't detect any problems in my code.

I found this post, [How to use MallocStackLogging on the device?](http://stackoverflow.com/questions/5167557/how-to-use-mallocstacklogging-on-the-device) on stackoverflow.
But nobody didn't give any helpful responses.


How to use
-------------------------
First of all, read a very useful Apple's technical note, [iOS Debugging Magic](https://developer.apple.com/library/ios/#technotes/tn2239/_index.html).
As mentioned in it, set the following environment variables

* MallocStackLogging YES
* MallocStackLoggingCompact YES
* NSDebug YES (not sure, but probably required when release build)

The variables MallocStackLogging and MallocStackLoggingCompact have the same meaning "Malloc stack" in  Diagnostics pane in scheme editing.

Now you'll see some messages in XCode debugger console like this:

    AppName(PID) malloc: recording malloc stacks to disk using standard recorder
    AppName(PID) malloc: stack logs being written into /private/var/mobile/Applications/<ApplicationId>/tmp/stack-logs.PID.AppName.index

Copy the file stack-logs.PID.AppName.index from your device to your Mac.
You can use tools such as [iExpolorer](http://www.macroplant.com/iexplorer/).
OK. Now, you're ready. Type the following command on your Mac:

    ruby iOS-malloc-stack-log-decoder stack-logs.PID.AppName.index


TODO
-------------------------
I'd like to be able to debug my apps on iOS devices at the same level on the simulator.
malloc_history command has lots of features, but, unfortunately, it doesn't work on iOS devices.
Malloc stack logs doesn't have any information about Objective-C's objects as I revealed.
How can malloc_history command show the name of objects and call stack or more?
malloc_history works well only if the target process is alive.
That's the key to understand how malloc_history works, I think.
Does anybody know any information about the mechanism of malloc_history?

