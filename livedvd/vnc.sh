apt-get update
apt-get install -y emacs 
export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get update
sudo -E apt-get install -y ubuntu-desktop
sudo apt-get install -y xrdp
sudo apt-get install -y xfce4 xfce4-goodies
#cd
#mkdir src
#cd src
#wget https://github.com/neutrinolabs/xrdp/archive/devel.zip
#unzip devel.zip
#cd xrdp-devel
#sudo apt-get install -y autoconf libtool libssl-dev libpam0g-dev libx11-dev libxfixes-dev libxrandr-dev
#./bootstrap
#./configure
#make
#sudo make install
echo xfce4-session > ~/.xsession
sudo cp /home/ubuntu/.xsession /etc/skel
\cp -f xrdp2.ini /etc/xrdp/xrdp.ini
sudo service xrdp restart
sudo apt-get install -y vnc4server
\cp -f xstartup ~/.vnc/xstartup
