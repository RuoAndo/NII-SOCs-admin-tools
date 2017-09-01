# transition to python 3

installing pyenv
<pre>
git clone https://github.com/yyuu/pyenv.git ~/.pyenv
</pre>

installing 3.5.1
<pre>
pyenv install 3.5.1
pyenv global 3.5.1
</pre>

installing virtualenv
<pre>
git clone https://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
</pre>

appending this to .bashrc
<pre>
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
</pre>

installing imports

<pre>
pip install pandas
pip install matplotlib
</pre>
