## Skedge :mouse:

### Thesis

[See the thesis on this project here!](https://github.com/dingbat/skedge-thesis)

### Developing

- Install Postgres 9.5 (on mac, Postgres.app is great for this)
- Install necessary gems:

  ```
  $ bundle install
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
    $ ansible-playbook -i inventory-prod.ini playbook.yml
    ```
    This installs Ruby, Postgres, Nginx, and may take some time on the first run.
  - Then go back & deploy skedge to it:
  
    ```
    $ cd ..
    $ cap production deploy
    ```
