planet
=====

This project depends on node.js.  I found instructions for installing node.js on OS X at the [Team Tree House blog](http://blog.teamtreehouse.com/install-node-js-npm-mac).  In a nutshell:
- Install XCode via the app store
- Install Homebrew via the terminal: `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
- Install Node via Homebrew: `brew install node`
- Afterwards I had to fix permissions in the node_modules folder `sudo chown -R <username>:admin /usr/local/lib/node_modules`
Once node.js is installed:
- Get the planet source: `git clone https://github.com/EliasGoldberg/planet.git`
- Navigate to the newly created `planet` directory
- Install the dev dependencies: `npm install`

To compile the coffeescript into javascript whenever a .coffee file is changed:
- Install coffee-script globally: `npm install -g coffeescript`
- In a new terminal window, navigate to the project directory
- `coffee -wcm src/*.coffee spec/*.coffee`

To run unit tests:
- Install Firefox (Or change the karma.conf.js file to use Chrome or whatever.)
- `karma run`

To run unit tests whenever you save a file:
- Install a bunch of dependencies globally: `npm install -g jasmine karma karma-jasmine karma-chrome-launcher`
- In a new terminal window: `karma start`

To serve the project locally:
- Install the global dependencies: `npm install -g connect serve-static`
- In a new terminal window: `node server.js`
- In your favorite browser, navigate to `localhost:8080`

To reload the project in the browser whenever a file is saved:
- Install yet more global dependencies: `npm install -g supervisor reload`
- Start the file watcher: `reload` (you cannot have the `node server.js` command running while doing this.  Navigate to localhost:8080/src/index.html.  Using -d or -s to specify the index page seems to prevent the debugger from accessing the .coffee files.)