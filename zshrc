
if [ ! $(echo "$0" | grep -s "zsh") ]; then
	echo "error: Not in zsh" 1>&2
	return;
fi

source $HOME/.zsh-antigen/antigen.zsh


antigen bundle $HOME/.zsh/


