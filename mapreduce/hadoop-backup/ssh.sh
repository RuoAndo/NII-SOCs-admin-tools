mkdir ~/.ssh
chmod 700 .ssh
cd .ssh
ssh-keygen -t rsa
cp id_rsa.pub authorized_keys
ssh localhost
