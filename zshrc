
if [ ! $(echo "$0" | grep -s "zsh") ]; then
	echo "error: Not in zsh" 1>&2
	return;
fi



### USEFUL VARS ###

_TERM="$TERM"
TERM="xterm-256color" && [[ $(tput colors) == 256 ]] || echo "can't use xterm-256color :/" # check if xterm-256 color is available, or if we are in a dumb shell

typeset -Ug PATH				# do not accept doubles

WORDCHARS="*?_-.[]~=/&;!#$%^(){}<>|"


PWD_FILE=~/.pwd					# last pwd sav file

OS="$(uname | tr "A-Z" "a-z")"	# get the os name

UPDATE_TERM_TITLE="" # set to update the term title according to the path and the currently executed line

EDITOR="vim"
VISUAL="vim"
PAGER="less"


CLICOLOR=1

case "$OS" in
	(*darwin*)					# Mac os
		LS_COLORS='exfxcxdxbxexexabagacad';;
	(*cygwin*)					# cygwin
		LS_COLORS='fi=1;32:di=1;34:ln=35:so=32:pi=0;33:ex=32:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=1;34:ow=1;34:';;
	(*linux*|*)					# Linux
		LS_COLORS='fi=1;34:di=1;34:ln=35:so=32:pi=0;33:ex=32:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=1;34:ow=1;34:';;
esac

DEF_C="$(tput sgr0)"

C_BLACK="$(tput setaf 0)"
C_RED="$(tput setaf 1)"
C_GREEN="$(tput setaf 2)"
C_YELLOW="$(tput setaf 3)"
C_BLUE="$(tput setaf 4)"
C_PURPLE="$(tput setaf 5)"
C_CYAN="$(tput setaf 6)"
C_WHITE="$(tput setaf 7)"
C_GREY="$(tput setaf 8)"

    
### (UN)SETTING ZSH (COOL) OPTIONS ###

setopt prompt_subst				# compute PS1 at each prompt print
setopt auto_remove_slash		# remove slash when pressing space in auto completion
setopt null_glob				# remove pointless globs
setopt auto_cd					# './dir' = 'cd dir'
setopt auto_push_d					# './dir' = 'cd dir'
setopt c_bases					# c-like bases conversions
setopt c_precedences			# c-like operators
setopt emacs					# enable emacs like keybindigs
setopt flow_control				# enable C-q and C-s to control the flooow
setopt complete_in_word			# complete from anywhere
setopt clobber					# i aint no pussy
setopt extended_glob			# used in matching im some functions
setopt multi_os					# no more tee !

unsetopt beep					# no disturbing sounds




autoload -U compinit
compinit						# enable completion
zmodload zsh/complist			# load compeltion list


for file in ~/.zsh/*.zsh;
do
    [ -e $file ] && source $file
done


[ -e ~/.myzshrc ] && source ~/.myzshrc # load user file if any
[ -e ~/.preszhrc ] && source ~/.preszhrc








PS4="%N:%i> ";
function setps4 ()				# toggle PS4 (xtrace prompt) between verbose and default
{
	case "$PS4" in
		("%b%N:%I %_
%B")
			PS4="%N:%i> ";
			;;
		(*)
			PS4="%b%N:%I %_
%B";
	esac 
}


### CALLBACK FUNCTIONS ###

function chpwd()				# chpwd hook
{
	check_git_repo
	set_git_branch
	update_pwd_datas
	update_pwd_save
	setprompt					# update the prompt
}


function preexec()				# pre execution hook
{
	[ -z $UPDATE_TERM_TITLE ] || printf "\e]2;%s : %s\a" "${PWD/~/~}" "$1" # set 'pwd + cmd' set term title
}

function precmd()				# pre promt hook
{
	[ -z $UPDATE_TERM_TITLE ] || printf "\e]2;%s\a" "${PWD/~/~}" # set pwd as term title
	
	set_git_char
}









### ZSH FUNCTIONS LOAD ###

autoload add-zsh-hook			# control the hooks (chpwd, precmd, ...)
autoload zed					# zsh editor
autoload zargs					# xargs like in shell
autoload _setxkbmap				# load setxkbmap autocompletion

# autoload predict-on			# fish like suggestion (with bundled lags !)
# predict-on

autoload -z edit-command-line	# edit command line with $EDITOR
zle -N edit-command-line

autoload -U colors && colors	# cool colors



### SETTING UP ZSH COMPLETION STUFF ###

zstyle ':completion:*:(rm|cp|mv|emacs):*' ignore-line yes # remove suggestion if already in selection
zstyle ':completion:*' ignore-parents parent pwd		  # avoid stupid ./../currend_dir

zstyle ":completion:*" menu select # select menu completion

zstyle ':completion:*:*' list-colors ${(s.:.)LS_COLORS} # ls colors for files/dirs completion

zstyle ":completion:*" group-name "" # group completion

zstyle ":completion:*:warnings" format "Nope !" # custom error

zstyle ":completion:::::" completer _complete _approximate # approx completion after regular one
zstyle ":completion:*:approximate:*" max-errors "(( ($#BUFFER)/3 ))" # allow one error each 3 characters

zle -C complete-file complete-word _generic
zstyle ':completion:complete-file::::' completer _files

zstyle ':completion:*' file-sort modification # newest files at first

zstyle ":completion:*:descriptions" format "%B%d%b" # completion group in bold

compdef _setxkbmap setxkbmap	# activate setxkbmap autocompletion


### HOMEMADE FUNCTIONS COMPLETION ###

_ff() { _alternative "args:type:(( 'h:search in hidden files' 'e:search for empty files' 'r:search for files with the reading right' 'w:search for files with the writing right' 'x:search for files with the execution right' 'b:search for block files' 'c:search for character files' 'd:search for directories' 'f:search for regular files' 'l:search for symlinks' 'p:search for fifo files' 'nh:exclude hidden files' 'ne:exclude empty files' 'nr:exclude files with the reading right' 'nw:exclude files with the writing right' 'nx:exclude files with the execution right' 'nb:exclude block files' 'nc:exclude character files' 'nd:exclude directories' 'nf:exclude regular files' 'nl:exclude symlinks symlinks' 'np:exclude fifo files' 'ns:exclude socket files'))" "*:root:_files" }
compdef _ff ff

_setprompt() { _arguments "1:prompt:(('complete:prompt with all the options' 'classic:classic prompt' 'lite:lite prompt' 'superlite:super lite prompt' 'nogit:default prompt without the git infos'))" }
compdef _setprompt setprompt

_loadconf() { _arguments "1:visual configuration:(('complete:complete configuration' 'static:complete configuration without the dynamic title and clock updates' 'lite:smaller configuration'))" }
compdef _loadconf loadconf

_kbd() { _alternative "1:layouts:(('us:qwerty keyboard layout' 'fr:azerty keyboard layout'))" "2:capslock rebinds:(('caps-ctrl:capslock as control' 'caps-esc:capslock as escape' 'caps-super:capslock as super'))" }
compdef _kbd kbd


### SHELL COMMANDS BINDS ###

# C-v or 'cat -v' to get the keycode
bindkey -s "^[j" "^A^Kjoin_others_shells\n" # join_others_shells user function
bindkey -s "^[r" "^Uressource\n"		  # source ~/.zshrc
bindkey -s "^[e" "^Uerror\n"			  # run error user function
bindkey -s "^[s" "^Asudo ^E"	# insert sudo
bindkey -s "^[g" "^A^Kgit commit -m\"\""
bindkey -s "^[c" "^A^Kgit checkout 		"
bindkey -s "\el" "^Uls\n"		# run ls
bindkey -s "\ed" "^Upwd\n"		# run pwd

bindkey -s ";;" "~"


### ZLE FUNCTIONS ###

function get_terminfo_name()	# get the terminfo name according to the keycode
{
	for k in "${(@k)terminfo}"; do
		[ "$terminfo[$k]" = "$@" ] && echo $k
	done
}


function open-delims() # open and close quoting chars and put the cursor at the beginning of the quoting
{
	if [ $# -eq 2 ]; then
		BUFFER="$LBUFFER$1$2$RBUFFER"
		CURSOR+=$#1;
	fi
}; zle -N open-delims

function sub-function() zle open-delims "\$(" ")"
zle -N sub-function

function simple-quote() zle open-delims \' \'
zle -N simple-quote

function double-quote() zle open-delims \" \"
zle -N double-quote

function save-line()			# save the current line at its state in ~/.saved_commands
{
	echo $BUFFER >> ~/.saved_commands
}; zle -N save-line

function ctrlz()
{
	suspend;
}; zle -N ctrlz

function clear-and-accept()		# clear the screen and accepts the line
{
	zle clear-screen;
	[ $#BUFFER -ne 0 ] && zle accept-line;
}; zle -N clear-and-accept

function move-text-right()		# shift text after cursor to the right
{
	BUFFER="${BUFFER:0:$CURSOR} ${BUFFER:$CURSOR}";
	CURSOR+=1;
}; zle -N move-text-right

function move-text-left()		# shift text after cursor to the left
{
	if [ $CURSOR -ne 0 ]; then
		BUFFER="${BUFFER:0:$((CURSOR-1))}${BUFFER:$CURSOR}";
		CURSOR+=-1;
	fi
}; zle -N move-text-left

function shift-arrow()			# emacs-like shift selection
{
	((REGION_ACTIVE)) || zle set-mark-command;
	zle $1;
}; zle -N shift-arrow

function select-left() shift-arrow backward-char; zle -N select-left
function select-right() shift-arrow forward-char; zle -N select-right

function get-word-at-point()
{
	echo "${LBUFFER/* /}${RBUFFER/ */}";
}; zle -N get-word-at-point


function self-insert-hook() # hook after each non-binded key pressed
{
	
}; zle -N self-insert-hook

function self-insert()			# call pre hook, insert key, and cal post hook
{
	zle .self-insert;
	zle self-insert-hook;
}; zle -N self-insert

function show-kill-ring()
{
	local kr;
	kr="=> $CUTBUFFER";
	for k in $killring; do
		kr+=", $k"
	done
	zle -M "$kr";
}; zle -N show-kill-ring


### ZSH FUNCTIONS BINDS ###

bindkey -e				  # load emacs style key binding


typeset -Ag key			  # associative array with more explicit names

key[up]=$terminfo[kcuu1]
key[down]=$terminfo[kcud1]
key[left]=$terminfo[kcub1]
key[right]=$terminfo[kcuf1]

key[C-up]="^[[1;5A"
key[C-down]="^[[1;5B"
key[C-left]="^[[1;5D"
key[C-right]="^[[1;5C"

key[M-up]="^[[1;3A"
key[M-down]="^[[1;3B"
key[M-left]="^[[1;3D"
key[M-right]="^[[1;3C"

key[S-up]=$terminfo[kri]
key[S-down]=$terminfo[kind]
key[S-left]=$terminfo[kLFT]
key[S-right]=$terminfo[kRIT]

key[tab]=$terminfo[kRIT]
key[S-tab]=$terminfo[cbt]

key[C-space]="^@"

key[enter]=$terminfo[cr]
key[M-enter]="^[^J"
case "$OS" in
	(*cygwin*) 	key[C-enter]="^^";;
	(*) 		key[C-enter]="^J";;
esac

key[F1]=$terminfo[kf1]
key[F2]=$terminfo[kf2]
key[F3]=$terminfo[kf3]
key[F4]=$terminfo[kf4]
key[F5]=$terminfo[kf5]
key[F6]=$terminfo[kf6]
key[F7]=$terminfo[kf7]
key[F8]=$terminfo[kf8]
key[F9]=$terminfo[kf9]
key[F10]=$terminfo[kf10]
key[F11]=$terminfo[kf11]
key[F12]=$terminfo[kf12]



bindkey $key[left] backward-char
bindkey $key[right] forward-char

bindkey $key[M-right] move-text-right
bindkey $key[M-left] move-text-left

bindkey "^X^E" edit-command-line # edit line with $EDITOR

bindkey "^Z" ctrlz			# ctrl z zsh

bindkey "^D" delete-char

bindkey "^X^X" exchange-point-and-mark

bindkey "^X^K" show-kill-ring

bindkey "\`\`" sub-function
bindkey "\'\'" simple-quote
bindkey "\"\"" double-quote

bindkey $key[C-left] backward-word
bindkey $key[C-right] forward-word

bindkey "^[k" kill-word
bindkey "^W" kill-region		 # emacs-like kill

bindkey "^Y" yank				# paste
bindkey "^[y" yank-pop			# rotate yank array

bindkey $key[S-tab] reverse-menu-complete # shift tab for backward completion

bindkey "^[=" save-line



bindkey $key[S-right] select-right # emacs like shift selection
bindkey $key[S-left] select-left

bindkey $key[C-enter] clear-and-accept

bindkey $key[F1] run-help
bindkey $key[F5] clear-screen

### USEFUL ALIASES ###


### MANDATORY FUNCTIONS CALLS ###

check_git_repo
set_git_branch
update_pwd_datas
update_pwd_save
set_git_char
loadconf static
title
rehash							# hash commands in path

setprompt classic

[ -e ~/.postzshrc ] && source ~/.postzshrc # load user file if any

# join_others_shells				# ask to join others shells

[ "$STARTUP_CMD" != "" ] && eval $STARTUP_CMD && unset STARTUP_CMD; # execute user defined commands after init

