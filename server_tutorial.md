[Valve wiki](https://developer.valvesoftware.com/wiki/SteamCMD#Linux)

[HOW TO INSTALL AND USE STEAMCMD](https://danielgibbs.co.uk/2014/02/steamcmd/)

[Launching and Configuring Counter-Strike 1.6 Server on Linux](https://ixnfo.com/en/launching-and-configuring-counter-strike-1-6-server-on-linux.html)

[How to install Counter Strike 1.6 Server in Linux (Ubuntu/CentOS/Debian)](https://thencoders.com/how-to-install-counter-strike-1-6-server-in-linux-ubuntu-centos-debian/)



# Tutorial for Ubuntu 64 bit

## Prerequisite

`1.` As the root user, create a steam user:

    useradd -m steam

`2.` Go into its home folder:

    cd /home/steam

`3.` Install Package from repositories

    sudo add-apt-repository multiverse
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install lib32gcc1 steamcmd 

`4.`  Link the steamcmd executable:

    ln -s /usr/games/steamcmd steamcmd

`5.` Install the dependencies required to run SteamCMD:

    sudo apt-get install lib32gcc1

`6.` Switch to steam user:

    su - steam

`7.` If you're not logging in as root and you instead use sudo to perform administration, escalate to the steam user as follows:

    sudo -iu steam

`8.` Create a directory for SteamCMD and switch to it.

    mkdir ~/Steam && cd ~/Steam


`9.` Download and extract SteamCMD

    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

`10.` Install tmux and/or screen for easy server management (Optional)

    sudo apt-get install tmux screen -y;

## Running SteamCMD

On first run, SteamCMD will automatically update and enter you into a Steam> prompt. Type help for more information.

`11.` Run it

    cd ~/Steam
    ./steamcmd.sh

`12.` Set your app install directory and login anonymously.

    force_install_dir ./csserver/
    login anonymous

`13.` Download and validate (only first time) game files

    app_set_config 90 mod cstrike
    app_update 90 validate
    app_update 90 validate
    app_update 90 -beta beta validate
    app_update 90 -beta beta validate
    quit

`14.` Go to the directory with the downloaded files and try to run the Counter-Strike 1.6 server for the test:

    cd ~/csserver
    ./hlds_run -game cstrike +ip 0.0.0.0 +maxplayers 12 +map de_dust2

If everything is ok, interrupt the server by typing quit or pressing CTRL+C.

`15.` Run a new Screen session and start the server (where 192.168.1.50 is your dedicated IP that is visible from the Internet):

    screen -a
    cd ~/csserver
    ./hlds_run -game cstrike +ip 192.168.0.11 +port 27017 +maxplayers 21 +sv_lan 0 -insecure -pingboost 3 +sys_ticrate 1030 -debug +condebug +map awesome_cars2


`16.` On linux servers, you may experience a "Login Failure: No Connection" error. This is related to missing iptables rules. You will want something along these lines:

    iptables -A INPUT -p udp -m udp --sport 27000:27030 --dport 1025:65355 -j ACCEPT
    iptables -A INPUT -p udp -m udp --sport 4380 --dport 1025:65355 -j ACCEPT

# Problems and solutoins

- P: this message when start server
```txt
/home/<username>/.steam/sdk32/steamclient.so
with error:
/home/<username>/.steam/sdk32/steamclient.so: cannot open shared object file: No such file or directory
```
- S: [link to explanation](https://forums.alliedmods.net/showpost.php?p=1973259&postcount=12)

```txt
Valve thought it would be a good idea to look for the Steam Client library and use the same library for both the server and client.

From what I can tell from previous comments by Valve, this check was only supposed to happen the first time ever that you started the server and never mention it again (Source: Alfred Reynolds), but srcds checks for it on every startup, then uses its own copy if it's not found..

The dumb thing? Sharing this library between client and server causes more problems than it fixes, as if you have an out of date Steam Linux client on the same machine, the server does weird things or crashes. 
```

- P: ['ERROR: couldn't open custom.hpk'](https://forums.alliedmods.net/showthread.php?t=334119), take a look into [this one](https://askubuntu.com/questions/774879/definitive-permission-to-folder) too
- S: `chmod -R <permissionsettings> <dirname>` and then change map like so: `changelevel de_aztec`
- Example: `chmod -R 777 csserver/`

- p: Failed to init SDL priority manager: SDL not found and Failed to set thread priority: per-thread setup failed
- S: https://github.com/ValveSoftware/steam-for-linux/issues/7036

- P: When you close terminal server goes offline
- S: Use [Screen](https://linuxize.com/post/how-to-use-linux-screen/)

Go in the folder of the server and use this command (first switch to `steam` user `sudo su - steam`)

        cd ~/Steam/csserver
        screen -S csserver ./hlds_run -game cstrike +ip 192.168.0.11 +port 27017 +maxplayers 21 +sv_lan 0 -insecure -pingboost 3 +sys_ticrate 1030 -debug +condebug +map awesome_cars2

[How to kill a session](https://stackoverflow.com/questions/1509677/kill-detached-screen-session)

    screen -X -S [session # you want to kill] kill
    screen -X -S csserver kill

Use the key sequence `Ctrl-a` + `Ctrl-d` to detach from the screen session.

Reattach to the screen session by typing 

    screen -r [session id/name].

See running screen sessions

    screen -ls


- P: terminal does not my username that I created with `useradd`
- [S:](https://askubuntu.com/questions/388440/why-is-there-no-name-showing-at-the-command-line) sudo chsh -s /bin/bash `<username>` 


# Setup FTP access

[How To Set Up vsftpd for a User's Directory on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-vsftpd-for-a-user-s-directory-on-ubuntu-20-04)

## vsftpd

    sudo apt-get install vsftpd
    sudo nano /etc/vsftpd.conf

append or change the following settings
```conf
listen=YES
listen_ipv6=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
# your external ip here
pasv_address=130.204.202.133

pasv_enable=YES
pasv_min_port=40000
pasv_max_port=50000
# port you want if not default
listen_port=<ftp port>
force_local_logins_ssl=NO
force_local_data_ssl=NO
use_localtime=YES
```

    sudo systemctl restart vsftpd
    sudo systemctl status vsftpd

Forward ports `<ftp port>` and `40000` to `50000` (TCP) in your router

## Filezilla

Edit > Connection > FTP > Active mode > Limit local ports used > lowest `40000` highest `50000` ports
Edit > Connection > FTP > Active mode > Active mode IP > User the folowwing Ip address > 130.204.202.133 (your external ip here)


# sv_downloadurl

1. Folder with name of `cstrike`
2. in it include from your `cstrike` folder:
    - all `.wad` files
    - `gfx` folder
    - `maps` folder
    - `models` folder
    - `overviews` folder
    - `sound` folder
    - `sprites` folder
3. Find hosting and in their `public_html` upload yours
4. Lod domain and get link to `cstrike` folder
5. Update the value of `sv_downloadurl` "http://svdl2.myserv.eu/rented/81-27017/cstrike/" (example link) in your server `server.cfg` file

# UFW and IP tables

[How To Set Up a Firewall with UFW on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-20-04)
[How To List and Delete Iptables Firewall Rules](https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules)

- List the currently configured iptables rules:

        iptables -L

- Add rule

        sudo iptables -A INPUT -p udp -m udp --sport 27000:27030 --dport 1025:65355 -j ACCEPT
        sudo iptables -A INPUT -p udp -m udp --sport 4380 --dport 1025:65355 -j ACCEPT

- Delete rule

        sudo iptables -D INPUT -p udp -m udp --sport 27000:27030 --dport 1025:65355 -j ACCEPT

- Saving Changes

        sudo ufw status
        sudo /sbin/iptables-save


- Add rule with `ufw` 

        sudo ufw allow 27000:27030/tcp

- No need for TeamViewer port to be allowed in the firewall


# NGINX and sv_downloadurl setup
[How To Install Nginx on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04)
[Configuring an Nginx HTTPs Reverse Proxy on Ubuntu Bionic](https://www.scaleway.com/en/docs/tutorials/nginx-reverse-proxy/)


1. Installing Nginx

        sudo apt update
        sudo apt install nginx
        sudo ufw app list
        sudo ufw allow 'Nginx HTTP'


2. Setup Nginx
Open the public folder of nginx in the file system

        cd /var/www/

3. here we would need to create a folder with the name of our website

        sudo mkdir fastdl.gamewaver.com
        cd fastdl.gamewaver.com

4. Add A record in cloudflare for your domain

5. Create symbolink link to your cstrike folder

        sudo ln -s /home/steam/Steam/fastdl /var/www/fastdl.gamewaver.com

6. Unlink the default page because we won't need it anymore you can also move or rename it so its not anymore used

        sudo unlink /etc/nginx/sites-enabled/default

7. Create new .conf file for our website

        cd /etc/nginx/sites-available
        nano fastdl.gamewaver.com.conf

`fastdl.gamewaver.com.conf` 
```conf
server {
        listen 80;
        listen [::]:80;

        root /var/www/fastdl.gamewaver.com/fastdl;

        server_name fastdl.gamewaver.com www.fastdl.gamewaver.com;

        location / {
                autoindex on;
                autoindex_exact_size on;
        }
}

```

with this you will get 403 error from nginx and this is how to solve it

```txt
Another way to solve this issue is to allow Nginx to list directories if the index file is unavailable. Enable this module by adding the following entry to the configuration file.

location / {
autoindex on;
autoindex_exact_size on;
}
NOTE: We do not recommend this method on publicly accessible servers.
```

8. Link `fastdl.gamewaver.com.conf` to `sites-enabled` directory

        sudo ln -s /etc/nginx/sites-available/fastdl.gamewaver.com.conf /etc/nginx/sites-enabled/fastdl.gamewaver.com.conf

And if you need to change something you have to change it in the file located in sites-available directory

In the end this would be the result `http://fastdl.gamewaver.com/cstrike/`

9. Restart Commands

        sudo systemctl restart nginx
        sudo systemctl reload nginx


# Server startup script
[Running Script or Command as Another User in Linux](https://www.baeldung.com/linux/run-as-another-user)

1. Switch to steam user and create `start.sh` file in the home directory for example
2. Give `start.sh` file permissions to be executable

        chmod +x start.sh

`start.sh`
```sh
echo "Running annie-script.sh as user $(whoami)"
echo "Working directory is $(pwd)"
```

3. Switch to your main user and and run the script from it but on behave of `steam` one

        su -c '/home/steam/start.sh' steam

Use this command when you are logged in as main user and want to start/restart the server

it would ask you for password and it should execute

4. Disabling the Password Prompt
Firstly, we open up the file /etc/pam.d/su with any text editor.

        sudo nano /etc/pam.d/su

Then, we’ll add the following lines into the file right after the line auth sufficient pam_rootok.so:

        auth  [success=ignore default=1] pam_succeed_if.so user = steam
        auth  sufficient                 pam_succeed_if.so use_uid user = <your main user>

After you save it and execute the above command (in 3.) it should not ask you for a password for the steam user

5. Update `start.sh` with the following:

```sh
screen -X -S csserver kill
cd /home/steam/Steam/csserver
screen -A -m -d -S csserver ./hlds_run -game cstrike +ip 192.168.0.11 +port 27017 +maxplayers 21 +sv_lan 0 -insecure -pingboost 3 +sys_ticrate 1030 -debug +condebug +map awesome_cars2
echo "==========Server has been booted=========="
```

6. Run `start.sh` script on system startup

[Run a Script on Startup in Linux](https://www.baeldung.com/linux/run-script-on-startup)
First login as the user you want to execute the script from, then open crontab and add the required line at the bottom of the file

        crontab -e
        @reboot sh /home/steam/start.sh




















