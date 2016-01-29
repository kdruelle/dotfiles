

function update_pwd_datas()		# update the numbers of files and dirs in .
{
	local v
	v=$(ls -pA1)
	NB_FILES=$(echo "$v" | grep -v /$ | wc -l | tr -d ' ')
	NB_DIRS=$(echo "$v" | grep /$ | wc -l | tr -d ' ')
}

function update_pwd_save()		# update the $PWD_FILE
{
	[[ $PWD != "$HOME" ]] && echo $PWD > $PWD_FILE
}



# Load PS1 Plugin
for plugin in ~/.zsh/ps1_mod/*.zsh; 
do  
    source "$plugin"; 
done



SEP_C="%F{242}"					# separator color
ID_C="%F{33}"					# id color
PWD_C="%F{201}"					# pwd color
NBF_C="%F{46}"					# files number color
NBD_C="%F{26}"					# dir number color
TIM_C="%U%B%F{220}"				# time color

GET_SHLVL="$([[ $SHLVL -gt 9 ]] && echo "+" || echo $SHLVL)" # get the shell level (0-9 or + if > 9)

GET_SSH="$([[ $(echo $SSH_TTY$SSH_CLIENT$SSH_CONNECTION) != '' ]] && echo ssh$SEP_C:)" # 'ssh:' before username if logged in ssh

PERIOD=5			  # period used to hook periodic function (in sec)

_PS1=()
_PS1_DOC=()

_ssh=1				;_PS1_DOC+="be prefixed if connected in ssh"
_user=2				;_PS1_DOC+="print the username"
_machine=3			;_PS1_DOC+="print the machine name"
_wd=4				;_PS1_DOC+="print the current working directory"
_git_branch=5		;_PS1_DOC+="print the current git branch if any"
_dir_infos=6		;_PS1_DOC+="print the nb of files and dirs in '.'"
_return_status=7	;_PS1_DOC+="print the return status of the last command (true/false)"
_git_status=8		;_PS1_DOC+="print the status of git with a colored char (clean/dirty/...)"
_jobs=9				;_PS1_DOC+="print the number of background jobs"
_shlvl=10			;_PS1_DOC+="print the current sh level (shell depth)"
_user_level=11		;_PS1_DOC+="print the current user level (root or not)"
_end_char=12		;_PS1_DOC+="print a nice '>' at the end"

function setprompt()			# set a special predefined prompt or update the prompt according to the prompt vars
{
	case $1 in
		("superlite") _PS1=("" "" "" "" "" "" "" "" "" "" "X" "");;
		("lite") _PS1=("X" "X" "X" "" "" "" "" "" "" "" "X" "X");;
		("nogit") _PS1=("X" "X" "X" "X" "" "X" "X" "" "X" "X" "X" "X");;
		("classic") _PS1=("X" "X" "X" "X" "X" "" "X" "X" "X" "X" "X" "X");;
		("complete") _PS1=("X" "X" "X" "X" "X" "X" "X" "X" "X" "X" "X" "X");;
	esac
	PS1=''																								# simple quotes for post evaluation
	[ ! -z $_PS1[$_ssh] ] 			&& 	PS1+='$ID_C$GET_SSH'												# 'ssh:' if in ssh
	[ ! -z $_PS1[$_user] ] 			&&	PS1+='$ID_C%n'														# username
	if [ ! -z $_PS1[$_user] ] && [ ! -z $_PS1[$_machine] ]; then
		PS1+='${SEP_C}@'
	fi
	[ ! -z $_PS1[$_machine] ]		&& 	PS1+='$ID_C%m'												# @machine
	if [ ! -z $_PS1[$_wd] ] || ( [ ! -z $GIT_BRANCH ] && [ ! -z $_PS1[$_git_branch] ]) || [ ! -z $_PS1[$_dir_infos] ]; then 					# print separators if there is infos inside
		PS1+='${SEP_C}['
	fi
	[ ! -z $_PS1[$_wd] ] 			&& 	PS1+='$PWD_C%~' 													# current short path
	if ( [ ! -z $_PS1[$_git_branch] ] && [ ! -z $GIT_BRANCH ] ) && [ ! -z $_PS1[$_wd] ]; then
		PS1+="${SEP_C}:";
	fi
	[ ! -z $_PS1[$_git_branch] ] 	&& 	PS1+='${GB_C}$GIT_BRANCH' 											# get current branch
	if ([ ! -z $_PS1[$_wd] ] || ( [ ! -z $GIT_BRANCH ] && [ ! -z $_PS1[$_git_branch] ])) && [ ! -z $_PS1[$_dir_infos] ]; then
		PS1+="${SEP_C}|";
	fi
	[ ! -z $_PS1[$_dir_infos] ] 	&& 	PS1+='$NBF_C$NB_FILES${SEP_C}/$NBD_C$NB_DIRS' 				# nb of files and dirs in .
	if [ ! -z $_PS1[$_wd] ] || ( [ ! -z $GIT_BRANCH ] && [ ! -z $_PS1[$_git_branch] ]) || [ ! -z $_PS1[$_dir_infos] ]; then 					# print separators if there is infos inside
		PS1+="${SEP_C}]%f%k"
	fi
	if ([ ! -z $_PS1[$_wd] ] || [ ! -z $_PS1[$_dir_infos] ]) || [ ! -z $_PS1[$_return_status] ] || [ ! -z $_PS1[$_git_status] ] || [ ! -z $_PS1[$_jobs] ] || [ ! -z $_PS1[$_shlvl] ] || [ ! -z $_PS1[$_user_level] ]; then
		PS1+="%f%k "
	fi
	[ ! -z $_PS1[$_return_status] ] && 	PS1+='%(0?.%F{82}o.%F{196}x)' 										# return status of last command (green O or red X)
-	[ ! -z $_PS1[$_git_status] ] 	&& 	PS1+='$GET_GIT'														# git status (red + -> dirty, orange + -> changes added, green + -> changes commited, green = -> changed pushed)
	[ ! -z $_PS1[$_jobs] ] 			&& 	PS1+='%(1j.%(10j.%F{208}+.%F{226}%j).%F{210}%j)' 					# number of running/sleeping bg jobs
	[ ! -z $_PS1[$_shlvl] ] 		&& 	PS1+='%F{205}$GET_SHLVL'						 					# static shlvl
	[ ! -z $_PS1[$_user_level] ] 	&& 	PS1+='%(0!.%F{196}#.%F{26}\$)'					 					# static user level
	[ ! -z $_PS1[$_end_char] ] 		&& 	PS1+='${SEP_C}>'
	[ ! -z "$PS1" ] 				&& 	PS1+="%f%k "
}

function pimpprompt()			# pimp the PS1 variables one by one
{
	local response;
	_PS1=("" "" "" "" "" "" "" "" "" "" "" "");
	echo "Do you want your prompt to:"
	for i in $(seq "$#_PS1"); do
		_PS1[$i]="X";
		setprompt;
		print "$_PS1_DOC[$i] like this ?\n$(print -P "$PS1")"
		read -q "response?(Y/n): ";
		if [ $response != "y" ]; then
		   	_PS1[$i]="";
			setprompt;
		fi
		echo;
		echo;
	done
}


function periodic()				# every $PERIOD secs - triggered by promt print
{
	check_git_repo
	set_git_branch
	update_pwd_datas
	update_pwd_save
}


