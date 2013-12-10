skedge
---

install:
```sh
$ [sudo] gem install rails
$ [sudo] gem install bundle
$ git clone https://github.com/RocHack/skedge.git
```

setup:
```sh
$ cd skedge
$ bundle           #install dependencies
$ rake db:migrate  #set up the db
$ rake scrape      #get some data
$ rails s          #start the server
```

& schedule some courses at [http://localhost:3000](http://localhost:3000)!