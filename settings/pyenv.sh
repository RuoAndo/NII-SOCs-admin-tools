yum install gcc bzip2 bzip2-devel openssl openssl-devel readline readline-devel                                         
cd /usr/local/                                                                                                          
git clone https://github.com/yyuu/pyenv.git ./pyenv                                                                       
cd /usr/local/pyenv/plugins/                                                                                            
git clone https://github.com/yyuu/pyenv-virtualenv.git                                                                    
echo 'export PYENV_ROOT="/usr/local/pyenv"' | tee -a /etc/profile.d/pyenv.sh                                        
echo 'export PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"' | tee -a /etc/profile.d/pyenv.sh                  
source /etc/profile.d/pyenv.sh                                                                                          
