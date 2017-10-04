## Laradock for FamousGrey Interactive

   Laradock is a configuration package for docker for Laravel but also for any other web project:
   - [Laradock Documentation](http://laradock.io/)

## Install Docker & Laradock

   - Download [Docker](https://www.docker.com/docker-mac)
   - Go to your web development directory and clone the Laradock repository:

         git clone https://github.com/famousinteractive/laradock.git

   - Remove the .git directory in the laradock directory:

         cd laradock && rm -rf .git

   - The architecture of your web development directory should be:
        + Project 1
        + Project 2
        + laradock

   - Once Laradock is installed, go the the Laradock directory and copy/rename env-example:

         cp env-example .env

   - Update this .env file 
   
        - with the right PHP version you want. 
        - you may need to update the default ports if you have conflicts with your current installation:

                MYSQL_PORT=3306 
                NGINX_HOST_HTTP_PORT=80
                NGINX_HOST_HTTPS_PORT=443
   
        - Check the variable `WORSPACE_INSTALL_XX` and `PHP_FPM_INSTALL_XX`. Setting the following to true is suggested : `NODE, YARN, IMAGEMAGICK`

   - Add the alias if you have a .aliases file in your home directory. Execute :

         echo "alias laradock-down=\"docker-compose down\"" >> ~/.aliases
         echo "alias laradock-up=\"docker-compose up -d nginx php-fpm workspace mariadb\"" >> ~/.aliases
         echo "alias laradock-restart=\"laradock-down && laradock-up\"" >> ~/.aliases
         reload

   - If not, add it to your bash_profile file. Execute : 

         echo "alias laradock-down=\"docker-compose down\"" >> ~/.bash_profile
         echo "alias laradock-up=\"docker-compose up -d nginx php-fpm workspace mariadb\"" >> ~/.bash_profile
         echo "alias laradock-restart=\"laradock-down && laradock-up\"" >> ~/.bash_profile

        Then refresh with:

         source ~/.bash_profile

   - Install `dockerproject` the helper to generate nginx config file and helper script

         wget https://raw.githubusercontent.com/famousinteractive/famous-interactive-laradock/master/dockerproject.sh
         mv dockerproject.sh /usr/local/bin/dockerproject && chmod +x /usr/local/bin/dockerproject


   - With this script you can run `dockerproject` and it will generate the nginx configuration and some sh scripts to help to manage the project.
                
            - Run the command inside your Php project
            - Update default prompted variable if required.
            - The script will set up the nginx config file, your local host and it'll restart docker with the default container. 
            - The nginx config files are in <laradockDirectory>/nginx/sites.

### Run
   - /!\ Read the known bugs below before running for the first time.
   - Go to the Laradock directory and execute the alias created previously:
   
         laradock-up
         
      Or the full version if you want something specific: 

         docker-compose up -d nginx php-fpm workspace mariadb

      Add phpmyadmin to use it (I suggest to use Sequel Pro instead)

          docker-compose up -d nginx php-fpm workspace mariadb phpmyadmin

      The parameters -d allow docker to run as a deamon.      

   - Or run the full build (not suggested as it's consume disk space and a lot of time):

            docker-compose build

   - Running command in your project via docker (Run these command inside your project)
        - Use `./docker-exec` (the alias created before) to connect to the docker machine
        - You can run command directly in your project by running

            `./docker-exec <command>`

            Example: `./docker-exec php artisan list`
            
   ### Stop
   
        laradock-stop
        
   ### Restart
        
        laradock-restart              

## Laradock known bug
   - You may have issue with the aws package in the laradock directory during the build. If so, go to aws/Dockerfile file and comment the following line

        `#COPY /ssh_keys/. /root/.ssh/`

        `#RUN cd /root/.ssh && chmod 600 * && chmod 644 *.pub`

   - With Php 5.6, the package php-worker will give you an error as the Dockerfile-56 don't exists yet. Copy Dockerfile-70 and update the line `FROM:php:7-alpine` with `FROM:php:5.6-alpine`

      Comment the line `RUN pecl channel-update pecl.php.net && pecl install memcached && docker-php-ext-enable memcached`

   - In case or issue, you call always remove the image or rebuild without cache `docker-compose build --no-cache`

## Connection to Mysql

   ### In your code

   - The DB HOST need to be `mariadb` (or `mysql` if you use mysql instead)
   - For Laravel, set `DB_HOST=mariadb` in the `.env` file

   ### Via sequel Pro

   - Host: 127.0.01
   - Username & passord: root / root or the one you set in .env file
   - Port: the one set, default is 3306

   ### Via phpmyadmin

   - Connect to 127.0.0.1:8080 (or the non-default port in .env). Host is `mysql`. login and password are root by default.
 
   ### Data's location

   - The datas are localized in `~/.laradock/data` on the host machine.
          
## Docker usefull commande

   - List running machine `docker ps`
   - Shutdown `docker-compose down` (in the laradock directory)
   - Kill `docker kill <id>` id comre from ps command
   - Clear unused image `docker image prune`
   - See existing images `docker images`
   - Remove an image `docker image <id|name>`
   - Delete all containers
      `docker rm $(docker ps -a -q)`
   - Delete all images
      `docker rmi $(docker images -q)`

## Php.ini

   - You can add specific info to the php.ini by updating the `laravel.ini` file in the php-fpm directory.
   - To add more execution time for your script, add this in the `laravel.ini`

         max_execution_time=480
         default_socket_timeout=3600
         request_terminate_timeout=480

        And this in your nginx config file

            fastcgi_read_timeout 480;

        Just before

            include fastcgi_params;
