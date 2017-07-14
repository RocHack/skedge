## Skedge :mouse:

### Thesis

[See the thesis on this project here!](https://github.com/dingbat/skedge-thesis)

### Developing

- Install Postgres 9.5 (on mac, Postgres.app is great for this)
- Install necessary gems:

  ```
  $ bundle install
  ```

  - Note: If you get any problems with `v8`, `the-ruby-racer`, or `nokogiri` try:
    (https://github.com/cowboyd/therubyracer/issues/403)
    ```
    xcode-select --install
    brew unlink v8
    brew install v8-315
    brew link --force v8-315
    gem install libv8 -v '3.16.14.13' -- --with-system-v8
    gem install therubyracer -v '0.12.2' -- --with-system-v8
    ```

- Set up the database:

  ```
  $ rake db:create
  $ rake db:migrate
  ```
- Scrape some data (for all or some departments)

  ```
  $ rake scrape
  $ rake scrape depts=csc,mth,ame
  ```
- Run the server

  ```
  $ rails s
  ```

### Running tests

Make sure Postgres is running and following command will run rSpec and Cucumber tests:

```
$ rake
```

Cucumber tests will require the local server to be running.

### Deploying

- If you want to submit a change, make a pull request and I can deploy it to http://skedgeur.com.
- If you want to deploy to your own server...(?!)
  - Set the IP of your server in `inventory-prod.ini`
  - Install required galaxy roles:
  
    ```
    $ cd infra
    $ ansible-galaxy install -r galaxy.txt
    ```
  - Configure your server with Ansible:
  
    ```
    $ ansible-playbook -i inventory-prod.ini web-playbook.yml
    ```
    This installs Ruby, Postgres, Nginx, and may take some time on the first run.
  - Then go back & deploy skedge to it:
  
    ```
    $ cd ..
    $ cap production deploy
    ```

