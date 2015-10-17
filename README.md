planet
=====

This project depends on node.js.  I found instructions for installing node.js on OS X at the [Team Tree House blog](http://blog.teamtreehouse.com/install-node-js-npm-mac).  In a nutshell:
- Install XCode via the app store
- Install Homebrew via the terminal: `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
- Install Node via Homebrew: `brew install node`

Once node.js is installed:
- Get the planet source: `git clone https://github.com/EliasGoldberg/planet.git`
- Navigate to the newly created `planet` directory
- Install the dev dependencies: `npm install`

To compile the coffeescript into javascript whenever a .coffee file is changed:
- Install coffee-script globally: `npm install -g coffee-script`
- In a new terminal window: `coffee -wcm src/*.coffee`

To run unit tests:
- Install Firefox (Or change the karma.conf.js file to use Chrome or whatever.)
- `karma run`

To run unit tests whenever you save a file:
- Install a bunch of dependencies globally :(
  - `npm install -g jasmine`
  - `npm install -g karma`
  - `npm install -g karma-jasmine`
  - `npm install -g karma-firefox-launcher`
- In a new terminal window: `karma start`
