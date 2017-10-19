# setting python3 and pyenv                                                                                             

<pre>                                                                                                                   
yum install gcc bzip2 bzip2-devel openssl openssl-devel readline readline-devel                                         
cd /usr/local/                                                                                                          
git clone git://github.com/yyuu/pyenv.git ./pyenv                                                                       
cd /usr/local/pyenv/plugins/                                                                                            
git clone git://github.com/yyuu/pyenv-virtualenv.git                                                                    
echo 'export PYENV_ROOT="/usr/local/pyenv"' | tee -a /etc/profile.d/pyenv.sh                                        
echo 'export PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"' | tee -a /etc/profile.d/pyenv.sh                  
source /etc/profile.d/pyenv.sh                                                                                          
</pre>

visudo 

<pre>
#Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin
Defaults    env_keep += "PATH"
Defaults    env_keep += "PYENV_ROOT"
</pre>

# iptables 

<pre>
iptables -I INPUT -p tcp --dport 6379 -j ACCEPT
</pre>