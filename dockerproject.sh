#!/bin/sh

## init  var

PROJECTNAME=""
ServerName=""
LARADOCKDIR=""
LARAVEL="Yes"

##Question

echo "Docker project starter"

while [ "$PROJECTNAME" = "" ]
 do
    echo " > Enter your project name (No space, no special chararacter, same name as the directory used) :"
        read PROJECTNAME
done

echo ""
echo "Vhost ServerName : [$PROJECTNAME.localhost]"
    read ServerName

    if [ "$ServerName" = "" ]; then
        ServerName="$PROJECTNAME.localhost"
    fi

echo ""
    while [ "$LARADOCKDIR" = "" ]
     do
        echo " > Absolute path to your Laradock Docker directory :"
            read LARADOCKDIR
    done

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

    cd $LARADOCKDIR/../
echo "#!/bin/sh

cd /var/www/$PROJECTNAME && \$*" > project--$PROJECTNAME

    if [ "$LARAVEL" == "Y" ] || [ "$LARAVEL" == "y" ]; then
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
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/letsencrypt/;
        log_not_found off;
    }

    error_log /var/log/nginx/laravel_error.log;
    access_log /var/log/nginx/laravel_access.log;
}
"   > $LARADOCKDIR/nginx/sites/$PROJECTNAME.conf

    else

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
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/letsencrypt/;
        log_not_found off;
    }

    error_log /var/log/nginx/app_error.log;
    access_log /var/log/nginx/app_access.log;
}

"   > $LARADOCKDIR/nginx/sites/$PROJECTNAME.conf

    fi
else
    exit
fi
