
# Check if a program is installed
function installed()
{
	if [ $# -eq 1 ]; then
        [ "$(type $1)" = "$1 not found" ] || return 0 &&  return 1
	fi
}

case "$OS" in
	(*darwin*)					# Mac os
		alias update="brew update && brew upgrade";
		alias install="brew install ";
		alias ls="ls -G";;
	(*cygwin*)					# cygwin
		alias ls="ls --color=auto";
		alias install="apt-cyg install ";;
	(*linux*|*)					# Linux
		alias update="sudo apt-get update && sudo apt-get upgrade";
		alias install="apt-get install ";
		alias ls="ls --color=auto";;
esac

alias ll="ls -lFh"
alias l="ll"
alias la="ls -lAFh"				# l with hidden files
alias lt="ls -ltFh"				# l with modification date sort
alias lt="ls -ltFh"				# l with modification date sort
alias l1="ls -1"				# one result per line

alias count="wc -l"
alias e="$EDITOR"
alias py="python"
alias ressource="source ~/.zshrc"
alias res="ressource"
#add-abbrev "cutf"	"| cut -d\  -f"
#add-abbrev "T"		"| tee "
#add-abbrev "tf"		"tail -fn0"
#add-abbrev "e"		"$EDITOR "
#add-abbrev "pp"		"$PAGER "
#add-abbrev "gb"		"git branch "
#add-abbrev "s2e"	"1>&2"
#add-abbrev "e2s"	"2>&1"
#add-abbrev "ns"		"1> /dev/null"
#add-abbrev "ne"		"2> /dev/null"
#add-abbrev "col"	'${COLUMNS}'
#add-abbrev "lin"	'${LINES}'


alias mkdir="mkdir -pv"			# create all the needed parent directories + inform user about creations

alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
installed tree && alias tree="tree -C"		   # -C colorzzz
installed colordiff && alias diff="colordiff" # diff with nicer colors
installed rsync && alias cpr="rsync -a --stats --progress" # faster
alias less="less -RS"			# -R Raw control chars, -S to truncate the long lines instead of folding them


alias size="du -sh"								# get the size of smthing
alias fatfiles="du -a . | sort -nr | head -n10" # get the 10 biggest files
alias df="df -Tha --total"		# disk usage infos
alias fps="ps | head -n1  && ps aux | grep -v grep | grep -i -e 'USER.*PID.*%CPU.*%MEM.*VSZ.*RSS TTY.*STAT.*START.*TIME COMMAND.*' -e " # fps <processname> to get ps infos only for the matching processes
alias tt="tail --retry -fn0"	# real time tail a log
alias dzsh="zsh --norcs --xtrace" # debugzsh

alias trunc='sed "s/^\(.\{0,$COLUMNS\}\).*$/\1/g"' # truncate too long lines


unset -f installed

