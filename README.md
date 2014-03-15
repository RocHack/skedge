skedge
---

stuff to install:
```sh
$ [sudo] gem install rails
$ [sudo] gem install bundler
$ brew install mongo
```

setup:
```sh
$ git clone https://github.com/RocHack/skedge.git
$ cd skedge
$ bundle              #install dependencies
$ mongod              #with & if you don't want to leave a tab open
$ rails s             #start the server
```

scraping cdcs data (do any of these):
```sh
$ rake scrape:all                 #this may take a really long time
$ rake scrape:all depts=csc,lin   #this will take less time
$ rake scrape:fall depts=csc,lin  #this will take even less time
```

then go to [http://localhost:3000](http://localhost:3000)!

