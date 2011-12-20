Purpose
=========================

Sometimes I like to log in to the RightScale control panel. Sometimes I like to use the native AWS control panel. Each works differently for different things. Right now, RightScale instance "nicknames" don't show up anywhere on the AWS control panel - so I have many instances with no name. It gets hard to figure out what's what.

So I quickly (and awfully) hacked together this script to run through our RightScale servers and set their AWS names to match. It also runs through any RightScale "Server Arrays" and sets those nicknames too.

Requirements
-------------------------
You'll need ruby 1.9.2 installed on your system. Well, it might also work with 1.8.6, but it hasn't for me. You'll need to install a few gems, if you don't have them -

```gem install amazon-ec2 crack```

You also need Rails - I think any version > 3 will do, but I'm not 100% sure. This gets you something you need from ActiveSupport. Don't ask me why you need it, I don't know. I just cobbled this thing together in an hour or two. Something to do with a particular dialect of YAML that RightScale speaks.

You'll also need the 'rs_api_examples' folder available from RightScale. I put that folder inside my folder for this project. You can get that from: http://support.rightscale.com/12-Guides/03-RightScale_API/RightScale_API_Examples

First, you need to log in to Rightscale - go to your rs_api_examples folder, go to 'bin', and then run rs_login.sh. This will set a cookie in your home/.rightscale folder.

Since I whacked together this script so quickly, you'll next have to change the path I've hardcoded in for my rightscale cookie. Wherever the rs_login.sh script dropped your cookie file, change the hardcoded paths in my script to match.

Then, you'll need to set your Amazon API credentials ("access key" and "secret access key") that are also hardcoded.

Finally, you'll have to grab your account ID (check the Rightscale Examples site for how to do this) and put it in the URL further down on the page. It's just a number.

TO DO
------------------------
I should probably not be using curl, and should use something like HTTParty. I should also just skip the whole rs_api_examples thing and directly jam in the appropriate URL's. Patches welcome if you feel up to fixing this yourself!

Apologies
----------------------
This is very very sloppy, and very very dirty. Sorry. I banged it out. I just expect to run it every week or so, by hand, to keep the names in sync between RightScale and AWS. If it gets on my nerves, I expect to fix it, otherwise, as long as it works, I'll leave it like this. Barring any well-assembled pull requests, of course :)
