## Laradock for Famous

   Laradock is a configuration package for docker for Laravel but also for any other web project. 
- [Laradock Doc](http://laradock.io/).

## Install Docker & Laradock

   - Download Docker (with docker-compose)
   - Go to your web development directory and git clone Laradock
        `git clone https://github.com/laradock/laradock.git`
   - Remove the .git directory in the laradock directory (`rm -rf .git`)     
   - The architecture of your web directory should be
        + Project-1
        + Project-2
        + laradock
   - One laradock can handle multiple project who require the same specification. If you want multiple specification (Php 5.6 and 7, ... ) you can create two laradock directoy
        + Project-1 (Php 5.6)
        + Project-2 (Php 7.2)
        + laradock-5.6
        + laradock-7.2
   - Once Laradock installed, go the the laradock directory and copy/rename env-example
   
        `cp env-example .env`
        
   - Update this .env file with the right Php version you want. Also, you may need to update the default port if you have conflict with your current installation 
        - MYSQL_PORT=3306 
        - NGINX_HOST_HTTP_PORT=80
        - NGINX_HOST_HTTPS_PORT=443        
   - Add the aliases, with famous mac installation and reload your terminal
        
        `echo "alias docker-exec=\"docker-compose exec --user=laradock workspace bash $*\"" >> ~/.aliases` 
        
        `reload`
        
        On other installation: `nano .bash_profile`, add the line and then refresh with `source ~/.bash_profile`
    
   - Move the dockerproject.sh file (the file is here if you don't have it yet: https://github.com/famousinteractive/laradock-and-famous/blob/master/dockerproject.sh ) : 
        `mv dockerproject.sh /usr/local/bin/dockerproject &&  chmod +x /usr/local/bin/dockerproject` 
         
        - This script will generate the nginx configuration and some sh script to help to manage the project.
            - You'll need to provide the path to your laradock directory (absolute path)
            - The project name need to be without special char & space.
            - The nginx config files are in `<laradockDirectory>/nginx/sites`
  
### Run            
   - In the laradock directory
        - `docker-compose build` and go take a coffee for you and your coworker. It's required only the first time and when you update the laradock .env file
        - `docker-compose up -d nginx php-fpm workspace mysql` (The -d run it as a deamon, you may want to remove it in some specific situation)      

   - Running command in your project via docker
        - Use `docker-exec` (the alias created before).
        - You can run `docker-compose exec --user=laradock workspace bash` in order to enter inside the VM machine
        - You can run command directly in your project by running 
        
            `docker-exec project--<PROJECTNAME> <command>`
            
            Example: `docker-exec project--test1 php artisan list`
         
## Laradock known bug
   - You may have issue with the aws package in the laradock directory during the build. If so, go to aws/Dockerfile file and comment the following line
        
        `#COPY /ssh_keys/. /root/.ssh/`
        
        `#RUN cd /root/.ssh && chmod 600 * && chmod 644 *.pub`   
               
## Docker usefull commande

   - List running machine `docker ps` 
   - Shutdown `docker-compose down` (in the laradock directory)
   - Kill `docker kill <id>` id comre from ps command
   - Clear unused image `docker image prune`
   - See existing images `docker images`
   - Remove an image `docker image <id|name>`
            
        
