# @rezaj_programmer

if [ "$(id -u)" -ne 0 ]; then
    echo -e "\033[33mPlease run as root\033[0m"
    exit
fi

wait 

colorized_echo() {
    local color=$1
    local text=$2
    
    case $color in
        "red")
        printf "\e[91m${text}\e[0m\n";;
        "green")
        printf "\e[92m${text}\e[0m\n";;
        "yellow")
        printf "\e[93m${text}\e[0m\n";;
        "blue")
        printf "\e[94m${text}\e[0m\n";;
        "magenta")
        printf "\e[95m${text}\e[0m\n";;
        "cyan")
        printf "\e[96m${text}\e[0m\n";;
        *)
            echo "${text}"
        ;;
    esac
}

colorized_echo green "\n[+] - Please wait for a few minutes, the bee config is being installed. . ."

# update proccess !
sudo apt update && apt upgrade -y
colorized_echo green "The server was successfully updated . . .\n"

# install packages !
PACKAGES=(
    mysql-server 
    libapache2-mod-php 
    lamp-server^ 
    php-mbstring 
    apache2 
    php-zip 
    php-gd 
    php-json 
    php-curl 
)

colorized_echo green " Installing the necessary packages. . ."

for i in "${PACKAGES[@]}"
    do
        dpkg -s $i &> /dev/null
        if [ $? -eq 0 ]; then
            colorized_echo yellow "Package $i is currently installed on your server!"
        else
            apt install $i -y
            if [ $? -ne 0 ]; then
                colorized_echo red "Package $i could not be installed."
                exit 1
            fi
        fi
    done

# install more !
echo 'phpmyadmin phpmyadmin/app-password-confirm password rezaj_programmer' | debconf-set-selections
echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
echo 'phpmyadmin phpmyadmin/mysql/admin-pass password rezaj_programmer' | debconf-set-selections
echo 'phpmyadmin phpmyadmin/mysql/app-pass password rezaj_programmer' | debconf-set-selections
echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections
sudo apt-get install phpmyadmin -y
sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin.conf
sudo systemctl restart apache2

wait

sudo apt-get install -y php-soap
sudo apt-get install libapache2-mod-php

# service proccessing !
sudo systemctl enable mysql.service
sudo systemctl start mysql.service
sudo systemctl enable apache2
sudo systemctl start apache2

ufw allow 'Apache Full'
sudo systemctl restart apache2

sleep 2

sudo apt install sshpass
sudo apt-get install pwgen
sudo apt-get install -y git
sudo apt-get install -y wget
sudo apt-get install -y unzip
sudo apt install curl -y
sudo apt-get install -y php-ssh2
sudo apt-get install -y libssh2-1-dev libssh2-1

sudo systemctl restart apache2.service

wait

clear
echo -e " \n"

read -p "[+] Enter The Domain without [http:// | https://]: " domain
if [ "$domain" = "" ]; then
    colorized_echo green "Ok, continue . . ."
    colorized_echo green "Please wait !"
    sleep 2
else
    DOMAIN="$domain"
fi

sudo ufw allow 80
sudo ufw allow 443 
sudo apt install letsencrypt -y
sudo apt-get -y install certbot python3-certbot-apache
sudo systemctl enable certbot.timer
sudo certbot certonly --standalone --agree-tos --preferred-challenges http -d $DOMAIN
sudo certbot --apache --agree-tos --preferred-challenges http -d $DOMAIN

clear

echo -e " \n"

wait

sleep 1
colorized_echo green "[+] Done"
echo -e "\n"