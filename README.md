## Laradock for FamousGrey Interactive

   Laradock is a configuration package for docker for Laravel but also for any other web project:
   - [Laradock Documentation](http://laradock.io/)

## Install Docker & Laradock

   - Download Docker (with docker-compose)
   - Go to your web development directory and clone the Laradock repository:

         git clone https://github.com/laradock/laradock.git

   - Remove the .git directory in the laradock directory:

         cd laradock && rm -rf .git

   - The architecture of your web development directory should be:
        + Project 1
        + Project 2
        + laradock

   - One Laradock installation can handle multiple projects that require the same setup. If you want multiple installations with different specifications (PHP 5.6, PHP 7.1, ...), you can create multiple Laradock directories:
        + Project-1 (PHP 5.6)
        + Project-2 (PHP 7.1)
        + laradock-5.6
        + laradock-7.1

   - Once Laradock is installed, go the the Laradock directory and copy/rename env-example:

         cp env-example .env

   - Update this .env file with the right PHP version you want.
   Also, you may need to update the default ports if you have conflicts with your current installation:

        MYSQL_PORT=3306
        NGINX_HOST_HTTP_PORT=80
        NGINX_HOST_HTTPS_PORT=443

   - Add the alias if you have a .aliases file in your home directory:

         echo "alias docker-exec=\"docker-compose exec --user=laradock workspace bash $*\"" >> ~/.aliases
         reload

   - If not:

         cd /~
         nano .bash_profile

   And add the line:

         echo "alias docker-exec=\"docker-compose exec --user=laradock workspace bash $*\"" >> ~/.aliases

   Then refresh with:

         source ~/.bash_profile

   - Clone this repository somewhere on your machine:

         git clone https://github.com/famousinteractive/famous-interactive-laradock.git

   - Move the dockerproject.sh file to your local bin directory and set the proper rights:

         mv dockerproject.sh /usr/local/bin/dockerproject && chmod +x /usr/local/bin/dockerproject

   - This script will generate the nginx configuration and some sh scripts to help to manage the project.
            - You'll need to provide the path to your Laradock directory (absolute path).
            - The project name needs to be without special characters and can't contain any spaces.
            - The nginx config files are in <laradockDirectory>/nginx/sites.

### Run
   - /!\ Read the known bugs below before running for the first time.
   - Go to the Laradock directory:

         docker-compose up -d nginx php-fpm workspace mariadb

      Add phpmyadmin to use it 

          docker-compose up -d nginx php-fpm workspace mariadb phpmyadmin

      The parameters -d allow docker to run as a deamon.      

   - Or run only the full build:

          docker-compose build

   - Running command in your project via docker (Run these command inside the laradock directory)
        - Use `docker-exec` (the alias created before).
        - You can run `docker-compose exec --user=laradock workspace bash` in order to enter inside the VM machine
        - You can run command directly in your project by running

            `docker-exec project--<PROJECTNAME> <command>`

            Example: `docker-exec project--test1 php artisan list`

## Laradock known bug
   - You may have issue with the aws package in the laradock directory during the build. If so, go to aws/Dockerfile file and comment the following line

        `#COPY /ssh_keys/. /root/.ssh/`

        `#RUN cd /root/.ssh && chmod 600 * && chmod 644 *.pub`

   - With Php 5.6, the package php-worker will give you an error as the Dockerfile-56 don't exists yet. Copy Dockerfile-70 and update the line `FROM:php:7-alpine` with `FROM:php:5.6-alpine`

      Comment the line `RUN pecl channel-update pecl.php.net && pecl install memcached && docker-php-ext-enable memcached`

   - In case or issue, you call always remove the image or rebuild without cache `docker-compose build --no-cache`


## For Laravel
    
   - Add or update in the .env of your Laravel folder the variable

         DB_HOST=mysql

## Connection to Mysql

   ### Via sequel Pro
   - Host: 127.0.01
   - Username & passord: root / root or the one you set in .env file
   - Port: the one set, default is 3306
   ### Via phpmyadmin
   - Connect to 127.0.0.1:8080 (or the non-default port in .env). Host is `mysql`. login and password are root by default.
          
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
            
