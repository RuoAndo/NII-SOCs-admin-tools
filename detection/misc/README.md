# maven path - .bashrc

<pre>
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias e='emacs --color=no'

if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export PATH=$PATH:/root/apache-maven-3.3.9/bin
</pre>

# building maven project

mvn archetype:generate \
      -DarchetypeArtifactId=maven-archetype-quickstart \
      -DinteractiveMode=false \
      -DgroupId=com.v4v6 \
      -DartifactId=v6