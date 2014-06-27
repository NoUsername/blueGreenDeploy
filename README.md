# Blue Green Deployment

Simple proof of concept of blue-green-deployment strategy with:

* Go dummy server application (serves as demo app)
* Bash shellscript (manages the deployment)
* Nginx as a proxy (provides easy & fast switching between backends)


## Running it

NOTE: this was developed on windows with cygwin (not tested on linux or OSX).

You can override the path variables (nginx conf dir & reload command) easily by creating a file called `deploy-conf.local` and setting the appropriate variables in there again.

	# in cygwin
	
	# on first run, update your nginx base config:
	cp nginx.conf C:/nginx/nginx.conf

	# simulate deploys:
	bash deploy.sh green
	# check http://localhost/ you should see that you are accessing the green backend
	
	# on next deploy:
	bash deploy.sh blue
	# check http://localhost/ you should see that you are accessing the blue backend
    

## Whats currently missing

1. stopping of backends before deploying the same one again
2. persistence of last-deployed backend + status

Ad 2: Currently you need to remember yourself which backend is active, so which one you want to deploy to.
When triggering deployment from an automated build-system this cannot work.
Another thing to consider is that this isn't just as simple as:

* deploy green
* deploy blue
* deploy green
* deploy blue
* ...

Think of this case:

* green is running find
* deploy new version to blue, blue gets activated (or not)
* you realize the blue version has a problem
* switch proxy back to using green backend
* now you have to deploy to blue backend again, although this was the last one that was deployed

