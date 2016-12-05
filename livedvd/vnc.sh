export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get update
sudo -E apt-get install -y ubuntu-desktop
sudo apt-get install -y xfce4 xrdp
sudo apt-get install -y xfce4 xfce4-goodies
echo xfce4-session > ~/.xsession
sudo cp /home/ubuntu/.xsession /etc/skel
\cp -f xrdp.ini /etc/xrdp/xrdp.ini
sudo apt-get install -y vnc4server
sudo service xrdp restart
