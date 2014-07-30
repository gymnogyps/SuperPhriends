# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

if [ -f $PWD/sandbox.sh ]; then
	. $PWD/sandbox.sh
fi


