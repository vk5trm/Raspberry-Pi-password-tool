#!/bin/bash
# script by RAMman
# Switch to root
if [ `whoami` != "root" ]; then
    echo "Please enter your root password below"
    su - -c "passwd-tool"
    exit
fi

## Starting the script
# Welcome message
 while true ; do

###############################################################################################################################################

# Please set the following variables for the system

DHOME=/home                                 # Sets the Home Directory
##################################################################################################################################################
hs=`hostname`
echo -e "${c}Script by RAMman,\

\nWelcome to RaspberryPi-Password-Tool.\
\n This mamagement tool lets  you create users,configure users passwords\
\n and remove users for user System accounts Open VPN and Samba file server. \

\nPlease answer all of the questions carefully and remember the passwords.\

\nRemember - you can break this at any time by pressing ctrl+c without any \
\nharm to your current system configuration.\

Please choose one of the menu items or just enter key to exit:\

\n		(a)   To Add a user Account\
\n 		(c)   To Change a Users Password / Access Rights\
\n 		(d)   To Delete a Users Account\

\nIts a good idea to set the a password for yourself if this is the first time\
\n you are using this system."$e #| fmt -w 80
read -e m1; echo
if [ "$m1" = "a" ]; then
clear
echo -e "${c}You want to add a user account.\
\nPlease enter the users name or just hit enter key to exit"$e #| fmt -w 80
read -e user; echo
 if [ "$user" != "" ]; then
    echo -e "${c}Do you want to select a Password.\
   \nPlease enter the password "$e #| fmt -w 80
    read -e password; echo
    if [ "$password" != "" ]; then
         if [ "$user" != "root" ]; then
             if [ "$user" != "pi" ]; then 
                useradd -g 100 -d $DHOME/$user -m -p $password $user
                echo "$user:$password" | chpasswd
                chown pi:pi $DHOME/$user
                chmod 755 $DHOME/$user/
                if [ -f "/usr/bin/smbpasswd" ]; then
                   echo -e "${c}Do you want to allow Samba access?\
                   \nPlease enter y for YES or just hit enter key for NO"$e #| fmt -w 80
                   read -e smb; echo
                   if [ "$smb" == "y" ]; then
                     echo -ne "$password\n$password\n" | smbpasswd -a -s $user
                     echo -e "${c}Do you want to allow Samba Write access?\
                     \nPlease enter y for YES or just hit enter key for NO"$e #| fmt -w 80
                     read -e smbW; echo
                     if [ "$smbW" == "y" ]; then
                       usermod -a -G sambashare $user
                fi
                   fi
                      fi
                 if [ -f "/usr/local/bin/pivpn" ]; then   
                    echo -e "${c}Do you want to allow VPN access?\
                    \nPlease enter y for YES or just hit enter key for NO"$e #| fmt -w 80
                    read -e vpn; echo
                    if [ "$vpn" == "y" ]; then
                    pivpn -a -d 1080 -n $user -p $password
                    echo "#   $password" >> /etc/openvpn/easy-rsa/pki/$user.ovpn
                    cp  /etc/openvpn/easy-rsa/pki/$user.ovpn $DHOME/$user/$user@$hs.ovpn
                    chown pi:pi $DHOME/$user/$user@$hs.ovpn
                    chmod 644 $DHOME/$user/$user@$hs.ovpn
                    rm /home/pi/ovpns/$user.ovpn
  fi
       fi
          fi
             fi
                 fi
                    fi
  break;
fi  

if [ "$m1" = "c" ]; then
   clear
   echo -e "${c}You want to change a password / Access Rights of a user account.\

   \nThis is the currant list of users\
   \n "$e #| fmt -w 80
   awk -F: '{if(($3 >1000)&&($3 <65534)) print $1}' /etc/passwd
   echo -e "${c}\
   \nPlease enter the users name or just hit enter to exit"$e #| fmt -w 80
   read -e user; echo
   if [ "$user" != "" ]; then
      echo -e "${c}You want to select a Password.\
      \nPlease enter the password"$e #| fmt -w 80
      read -e password; echo
      if [ "$password" != "" ]; then
          if [ "$user" != "root" ]; then
                if [ "$user" != "pi" ]; then 
                echo "$user:$password" | chpasswd
                if [ -f "/usr/bin/smbpasswd" ]; then
                   echo -e "${c}Do you want to allow Samba access?\
                   \nPlease enter y for YES or just hit enter key for NO"$e #| fmt -w 80
                   read -e smb; echo
                   if [ "$smb" == "y" ]; then
                     echo -ne "$password\n$password\n" | smbpasswd -a -s $user
                      echo -e "${c}Do you want to allow Samba Write access?\
                     \nPlease enter y for YES or just hit enter key for NO"$e #| fmt -w 80
                     read -e smbW; echo
                     if [ "$smbW" == "y" ]; then
                       usermod -a -G sambashare $user
                     else
                        usermod -G users $user  
                       fi
                  else
                      smbpasswd -x -s $user 
                      usermod -G users $user
                 fi
                    fi
                if [ -f "/usr/local/bin/pivpn" ]; then   
                    echo -e "${c}Do you want to allow VPN access?\
                    \nPlease enter y for YES or just hit enter key for NO"$e #| fmt -w 80
                    read -e vpn; echo
                    if [ "$vpn" == "y" ]; then
                       pivpn -r -y $user  
                       pivpn -a -d 1080 -n $user -p $password
                       echo "#   $password" >> /etc/openvpn/easy-rsa/pki/$user.ovpn
                       cp  /etc/openvpn/easy-rsa/pki/$user.ovpn $DHOME/$user/$user@$hs.ovpn 
                       chown pi:pi $DHOME/$user/$user@$hs.ovpn
                       chmod 644 $DHOME/$user/$user@$hs.ovpn
                       rm /home/pi/ovpns/$user.ovpn
                    else
                        if [ -f "/etc/openvpn/easy-rsa/pki/$user.ovpn" ]; then      
                          pivpn -r -y $user
                          rm $DHOME/$user/$user@$hs.ovpn 
                           if [ -d "/etc/openvpn/easy-rsa/pki/revoked" ]; then
                             rm /etc/openvpn/easy-rsa/pki/revoked/certs_by_serial/*.crt
                             rm /etc/openvpn/easy-rsa/pki/revoked/private_by_serial/*.key
                             rm /etc/openvpn/easy-rsa/pki/revoked/reqs_by_serial/*.req
                             sed -i '/^R/ d' /etc/openvpn/easy-rsa/pki/index.txt
                    
   fi
        fi
            fi
                 fi
                   fi
                        fi
                          fi
                            fi
 break;

 fi
if [ "$m1" = "d" ]; then
     clear
     echo -e "${c}You want to delete a user account.\

     \nThis is the currant list of users\
     \n "$e #| fmt -w 80
     awk -F: '{if(($3 >1000)&&($3 <65534)) print $1}' /etc/passwd
     echo -e "${c}\
     \nPlease enter the users name or just enter key to exit"$e #| fmt -w 80
     read -e user; echo
     if [ "$user" != ""  ]; then
        if [ "$user" != "root" ]; then
           if [ "$user" != "pi" ]; then
               if pdbedit -L "$user" &>/dev/null; then
                  smbpasswd -x -s $user 
                  fi            
              if [ -f "/etc/openvpn/easy-rsa/pki/$user.ovpn" ]; then
                 pivpn -r -y $user  
                 rm $DHOME/$user/$user@$hs.ovpn 
                 if [ -d "/etc/openvpn/easy-rsa/pki/revoked" ]; then
                    rm /etc/openvpn/easy-rsa/pki/revoked/certs_by_serial/*.crt
                    rm /etc/openvpn/easy-rsa/pki/revoked/private_by_serial/*.key
                    rm /etc/openvpn/easy-rsa/pki/revoked/reqs_by_serial/*.req
                    sed -i '/^R/ d' /etc/openvpn/easy-rsa/pki/index.txt
                    fi
             fi   
                 deluser $user
    fi
       fi
          fi
              
  break;
fi
done
