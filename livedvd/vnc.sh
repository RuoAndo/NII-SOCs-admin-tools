export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get update
sudo -E apt-get install -y ubuntu-desktop
sudo apt-get install xfce4 xrdp
sudo apt-get install xfce4 xfce4-goodies
echo xfce4-session > ~/.xsession
sudo cp /home/ubuntu/.xsession /etc/skel
