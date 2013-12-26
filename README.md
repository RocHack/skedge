skedge
---

install:
```sh
$ [sudo] gem install rails
$ [sudo] gem install bundler
$ git clone https://github.com/RocHack/skedge.git
```

setup:
```sh
$ cd skedge
$ bundle            #install dependencies
$ rake db:migrate   #set up the db
$ rails s           #start the server
```

scraping cdcs data (do any of these):
```sh
$ rake scrape:all               #this may take a really long time
$ rake scrape:all depts=csc,lin #this will take less time
$ rake scrape:all num=5         #this will also take less time
$ rake scrape:spring num=5      #this will take even less time
```

then go to [http://localhost:3000](http://localhost:3000)!

