#!/bin/sh

## init  var

PROJECTNAME=""
ServerName=""
LARAVEL="Yes"
LARADOCKDIR=""
CURRENT_DIRECTORY=${PWD##*/}

LARADOCKDIRDEFAULT="$PWD/../laradock"

LARADOCKDIRDEFAULT="$(cd $LARADOCKDIRDEFAULT; pwd)"


##Question

echo "Docker project starter"


echo " > Enter your project name (same name as the directory used) : [$CURRENT_DIRECTORY]"
    read PROJECTNAME

if [ "$PROJECTNAME" = "" ]; then
    PROJECTNAME="$CURRENT_DIRECTORY"
fi


echo ""
echo "Vhost ServerName : [$PROJECTNAME.localhost]"
    read ServerName

    if [ "$ServerName" = "" ]; then
        ServerName="$PROJECTNAME.localhost"
    fi

echo ""

echo " > Absolute path to your Laradock Docker directory : [$LARADOCKDIRDEFAULT]"
    read LARADOCKDIR

    if [ "$LARADOCKDIR" = "" ]; then
        LARADOCKDIR="$LARADOCKDIRDEFAULT"
    fi


echo ""
echo "Is it a Laravel Project ? [Y]/N"
    read LARAVEL

    if [ "$LARAVEL" = "" ]; then
        LARAVEL="Y"
    fi

    echo "Are you sure you want to create the vhost with the following data ?"

echo "Project: $PROJECTNAME"
echo "Local url: $ServerName"
echo "Laradock directory to use : $LARADOCKDIR"
echo "Use Laravel: $LARAVEL"

echo "> Y/N"
    read CONFIRMATION

if [ "$CONFIRMATION" == "Y" ] || [ "$CONFIRMATION" == "y" ]; then

echo "Write docker-exec script helper ..."

echo "
#!/bin/sh

if [ "\$#" -eq 0 ]; then
  cd $LARADOCKDIR
  docker-compose exec --user=laradock workspace bash
else
  if [ "\$1" == "pwd" ]; then
    cd $PROJECTNAME

    PARAMS="\${@:2}"
    echo \$PARAMS
    \$PARAMS
  else
    cd $LARADOCKDIR
    docker-compose exec --user=laradock workspace bash $PROJECTNAME/docker-exec pwd \$*
  fi
fi
" > docker-exec

chmod +x docker-exec

    if [ "$LARAVEL" == "Y" ] || [ "$LARAVEL" == "y" ]; then

echo "Write Nginx config file ..."
echo "server {

    listen 80;
    listen [::]:80;

    server_name $ServerName;
    root /var/www/$PROJECTNAME/public;
    index index.php index.html index.htm;

    location / {
         try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    location ~ \.php$ {
        try_files \$uri /index.php =404;
        fastcgi_pass php-upstream;
        fastcgi_index index.php;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
	fastcgi_param APPLICATION_ENV development;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/letsencrypt/;
        log_not_found off;
    }

    error_log /var/log/nginx/$PROJECTNAME.error.log;
    access_log /var/log/nginx/$PROJECTNAME.access.log;
}
"   > $LARADOCKDIR/nginx/sites/$PROJECTNAME.conf

    else
echo "Write Nginx config file ..."
echo "server {

    listen 80;
    listen [::]:80;

    server_name $ServerName;
    root /var/www/$PROJECTNAME;
    index index.php index.html index.htm;

    location / {
         try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    location ~ \.php$ {
        try_files \$uri /index.php =404;
        fastcgi_pass php-upstream;
        fastcgi_index index.php;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
	fastcgi_param APPLICATION_ENV development;
	include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/letsencrypt/;
        log_not_found off;
    }

    error_log /var/log/nginx/$PROJECTNAME.error.log;
    access_log /var/log/nginx/$PROJECTNAME.access.log;
}

"   > $LARADOCKDIR/nginx/sites/$PROJECTNAME.conf

    fi
else
    exit
fi

echo "Add hosts in your /etc/hosts files ..."

# insert/update hosts entry (https://stackoverflow.com/questions/19339248/append-line-to-etc-hosts-file-with-shell-script)
ip_address="127.0.0.1"
# find existing instances in the host file and save the line numbers
matches_in_hosts="$(grep -n $ServerName /etc/hosts | cut -f1 -d:)"
host_entry="${ip_address} ${ServerName}"

echo "Please enter your password if requested."

if [ ! -z "$matches_in_hosts" ]
then
    echo "Updating existing hosts entry."
    # iterate over the line numbers on which matches were found
    while read -r line_number; do
        # replace the text of each line with the desired host entry
        sudo sed -i '' "${line_number}s/.*/${host_entry} /" /etc/hosts
    done <<< "$matches_in_hosts"
else
    echo "Adding new hosts entry."
    echo "$host_entry" | sudo tee -a /etc/hosts > /dev/null
fi

echo "Restart docker with container [nginx php-fpm workspace mariadb] ..."

cd $LARADOCKDIR
docker-compose down
docker-compose up -d nginx php-fpm workspace mariadb phpmyadmin

echo "All Done!"
