### USEFUL USER FUNCTIONS ###


function escape()				# escape a string
{
	printf "%q\n" "$@";
}

function showcolors()			# display the 256 colors by shades - useful to get pimpy colors
{
	tput setaf 0;
	for c in {0..15}; do tput setab $c ; printf " % 2d " "$c"; done # 16 colors
	tput sgr0; echo;
	tput setaf 0;
	for s in {16..51}; do		# all the color tints
		for ((i = $s; i < 232; i+=36)); do
			tput setab $i ; printf "% 4d " "$i";
		done
		tput sgr0; echo; tput setaf 0;
	done
	for c in {232..255}; do tput setaf $((255 - c + 232)); tput setab $c ; printf "% 3d" "$c"; done # grey tints
	tput sgr0; echo;
}

#function error()				# give error nb to get the corresponding error string
#{
#	python -c "import os; print os.strerror($?)";
#}

function join_others_shells()	# ask for joining path specified in $PWD_FILE if not already in it
{
	if [[ -e $PWD_FILE ]] && [[ $(pwd) != $(cat $PWD_FILE) ]]; then
		read -q "?Go to $C_YELLOW$(cat $PWD_FILE)$C_WHITE ? (Y/n):" && cd "$(cat $PWD_FILE)"
	fi
}

function loop()					# loop parameter command every $LOOP_INT seconds (default 1)
{
	local d
	[ -z "$LOOP_INT" ] && LOOP_INT=1
	while true
	do
		clear
		d=$(date +%s)
		$@
		while [ "$(( $(date +%s) - d ))" -lt "$LOOP_INT" ]; do sleep 0.1; done
	done
}

function pc()			  		# percent of the home taken by this dir/file
{
	local subdir
	local dir

	if [ "$#" -eq 0 ]; then
		subdir=.
		dir=$HOME
	else if [ "$#" -eq 1 ]; then
			 subdir=$1
			 dir=$HOME
		 else if [ "$#" -eq 2 ]; then
				  subdir=$1
				  dir=$2
			  else
				  echo "Usage: pc <dir/file a>? <dir b>? to get the % of the usage of b by a"
				  return 1
			  fi
		 fi
	fi
	echo "$(($(du -sx $subdir | cut -f1) * 100 / $(du -sx $dir | cut -f1)))" "%"
}

function tmp()					# starts a new shubshell in /tmp
{
	env STARTUP_CMD="cd /tmp" zsh;
}

function -() 					# if 0 params, acts like 'cd -', else, act like the regular '-'
{
	[[ $# -eq 0 ]] && cd - || builtin - "$@"
}


# faster find allowing easier parameters in disorder
function ff()
{
	local p
	local name=""
	local type=""
	local additional=""
	local hidden=" -not -regex .*/\..*" # hide hidden files by default
	local root="."
	for p in "$@"; do
		if $(echo $p | grep -Eq "^n?[herwxbcdflps]$"); # is it a type ?
		then
			if $(echo $p | grep -q "n"); then # handle command negation
				neg=" -not"
				p=${p/n/}		# remove the 'n' from p, to get the real type
			else
				neg=""
			fi
			case $p in
				(h) [ -z $neg ] && hidden="" || hidden=" -not -regex .*/\..*";;
				(e) additional+="$neg -empty";;
				(r) additional+="$neg -readable";;
				(w) additional+="$neg -writable";;
				(x) additional+="$neg -executable";;
				(*) type+=$([ -z "$type" ] && echo "$neg -type $p" || echo " -or $neg -type $p");;
			esac
		else if [ -d $p ];		# is it a path ?
			 then
				 root=$p
			 else				# then its a name !
				 name+="$([ -z "$name" ] && echo " -name $p" || echo " -or -name $p")";
			 fi
		fi
	done
	if [ -t ]; then				# disable colors if piped
		find -O3 $(echo $root $name $additional $hidden $([ ! -z "$type" ] && echo "(") $type $([ ! -z "$type" ] && echo ")") | sed 's/ +/ /g') 2>/dev/null | grep --color=always "^\|[^/]*$" # re split all to spearate parameters and colorize filename
	else
		find -O3 $(echo $root $name $additional $hidden $type | sed 's/ +/ /g') 2>/dev/null
	fi
}

function colorcode()  			# get the code to set the corresponding fg color
{
	for c in "$@"; do
		tput setaf $c;
		echo -e "\"$(tput setaf $c | cat -v)\""
	done
}

function colorize() 			# cmd | colorize <exp1> (f/b)?<color1> <exp2> (f/b)?<color2> ... to colorize expr with color
{								# ie: cat log.log | colorize WARNING byellow ERROR bred DEBUG green INFO yellow "[0-9]+" 125 "\[[^\]]+\]" 207
	local -i i
	local last
	local params
	local col
	local background;
	i=0
	params=()
	col=""
	if [ $# -eq 0 ]; then
		echo "Usage: colorize <exp1> <color1> <exp2> <color2> ..." 1>&2
		return ;
	fi
	for c in "$@"; do
		if [ "$((i % 2))" -eq 1 ]; then
			case "$c[1]" in
				(b*)
					background="1";
					c="${c[2,$#c]}";;
				(f*)
					background="";
					c="${c[2,$#c]}";;
			esac
			case $c in
				("black") 	col=0;;
				("red") 	col=1;;
				("green") 	col=2;;
				("yellow") 	col=3;;
				("blue") 	col=4;;
				("purple") 	col=5;;
				("cyan") 	col=6;;
				("white") 	col=7;;
				(*) 		col=$c;;
			esac
			if [ $#background -ne 0 ]; then
				col="$(tput setab $col)";
			else
				col="$(tput setaf $col)";
			fi
			params+="-e";
			params+="s/(${last//\//\\/})/$col\1$DEF_C/g"; # replace all / by \/ to don't fuck the regex
		else
			last=$c
		fi
		i+=1;
	done
	if [ "$c" = "$last" ]; then
		echo "Usage: cmd | colorize <exp1> <color1> <exp2> <color2> ..."
		return
	fi
	# sed -r $params
	sed --unbuffered -r $params
}

function ts()					# timestamps operations (`ts` to get current, `ts <timestamp>` to know how long ago, `ts <timestamp1> <timestamp2>` timestamp diff)
{
	local -i delta;
	local -i ts1=$(echo $1 | grep -Eo "[0-9]+" | cut -d\  -f1);
	local -i ts2=$(echo $2 | grep -Eo "[0-9]+" | cut -d\  -f1);
	local sign;

	if [ $# = 0 ]; then
		date +%s;
	elif [ $# = 1 ]; then
		delta=$(( $(date +%s) - $ts1 ));
		if [ $delta -lt 0 ]; then
			delta=$(( -delta ));
			sign="in the future";
		else
			sign="ago";
		fi
		if [ $delta -gt 30758400 ]; then echo -n "$(( delta / 30758400 ))y "; delta=$(( delta % 30758400 )); fi
		if [ $delta -gt 86400 ]; then echo -n "$(( delta / 86400 ))d "; delta=$(( delta % 86400 )); fi
		if [ $delta -gt 3600 ]; then echo -n "$(( delta / 3600 ))h "; delta=$(( delta % 3600 )); fi
		if [ $delta -gt 60 ]; then echo -n "$(( delta / 60 ))m "; delta=$(( delta % 60 )); fi
		echo "${delta}s $sign";
	elif [ $# = 2 ]; then
		delta=$(( $ts2 - $ts1 ));
		if [ $delta -lt 0 ]; then
			delta=$(( -delta ));
		fi
		if [ $delta -gt 30758400 ]; then echo -n "$(( delta / 30758400 ))y "; delta=$(( delta % 30758400 )); fi
		if [ $delta -gt 86400 ]; then echo -n "$(( delta / 86400 ))d "; delta=$(( delta % 86400 )); fi
		if [ $delta -gt 3600 ]; then echo -n "$(( delta / 3600 ))h "; delta=$(( delta % 3600 )); fi
		if [ $delta -gt 60 ]; then echo -n "$(( delta / 60 ))m "; delta=$(( delta % 60 )); fi
		echo "${delta}s";
	fi
}

function rrm()					# real rm
{
	if [ "$1" != "$HOME" -a "$1" != "/" ]; then
		command rm $@;
	fi
}

RM_BACKUP_DIR="$HOME/.backup"
function rm()					# safe rm with timestamped backup
{
	if [ $# -gt 0 ]; then
		local backup;
		local idir;
		local rm_params;
		local i;
		idir="";
		rm_params="";
		backup="$RM_BACKUP_DIR/$(date +%s)";
		for i in "$@"; do
			if [ ${i:0:1} = "-" ]; then # if $i is an args list, save them
				rm_params+="$i";
			elif [ -f "$i" ] || [ -d "$i" ] || [ -L "$i" ] || [ -p "$i" ]; then # $i exist ?
				[ ! ${i:0:1} = "/" ] && i="$PWD/$i"; # if path is not absolute, make it absolute
				i="${i:A}";						# simplify the path
				idir="$(dirname $i)";
				command mkdir -p "$backup/$idir";
				mv "$i" "$backup$i";
			else				# $i is not a param list nor a file/dir
				echo "'$i' not found" 1>&2;
			fi
		done
	fi
}

function save()					# backup the files
{
	if [ $# -gt 0 ]; then
		local backup;
		local idir;
		local rm_params;
		local i;
		idir="";
		rm_params="";
		backup="$RM_BACKUP_DIR/$(date +%s)";
		command mkdir -p "$backup";
		for i in "$@"; do
			if [ ${i:0:1} = "-" ]; then # if $i is an args list, save them
				rm_params+="$i";
			elif [ -f "$i" ] || [ -d "$i" ] || [ -L "$i" ] || [ -p "$i" ]; then # $i exist ?
				[ ! ${i:0:1} = "/" ] && i="$PWD/$i"; # if path is not absolute, make it absolute
				i="${i:A}";						# simplify the path
				idir="$(dirname $i)";
				command mkdir -p "$backup/$idir";
				if [ -d "$i" ]; then
					cp -R "$i" "$backup$i";
				else
					cp "$i" "$backup$i";
				fi
			else				# $i is not a param list nor a file/dir
				echo "'$i' not found" 1>&2;
			fi
		done
	fi
}

CLEAR_LINE="$(tput sgr0; tput el1; tput cub 2)"
function back()					# list all backuped files
{
	local files;
	local peek;
	local backs;
	local to_restore="";
	local peeks_nbr=$(( (LINES) / 3 ));
	local b;
	local -i i;
	local key;

	[ -d $RM_BACKUP_DIR ] || return
	back=( $(command ls -t1 $RM_BACKUP_DIR/) );
	i=1;
	while [ $i -le $#back ] && [ -z "$to_restore" ]; do
		b=$back[i];
		files=( $(find $RM_BACKUP_DIR/$b -type f) )
		if [ ! $#files -eq 0 ]; then
			peek=""
			for f in $files; do peek+="$(basename $f), "; if [ $#peek -ge $COLUMNS ]; then break; fi; done
			peek=${peek:0:(-2)}; # remove the last ', '
			[ $#peek -gt $COLUMNS ] && peek="$(echo $peek | head -c $(( COLUMNS - 3 )) )..." # truncate and add '...' at the end if the peek is too large
			echo "$C_RED#$i$DEF_C: $C_GREEN$(ts $b)$DEF_C: $C_BLUE$(echo $files | wc -w)$DEF_C file(s) ($C_CYAN$(du -sh $RM_BACKUP_DIR/$b | cut -f1)$DEF_C)"
			echo "$peek";
			echo;
		fi
		if [ $(( i % $peeks_nbr == 0 || i == $#back )) -eq 1 ]; then
			key="";
			echo -n "> $C_GREEN";
			read -sk1 key;
			case "$(echo -n $key | cat -e)" in
				("^[")
					echo -n "$CLEAR_LINE";
					read -sk2 key; # handle 3 characters arrow key press as next
					i=$(( i + 1 ));;
				("$"|" ")			# hangle enter and space as next
					echo -n "$CLEAR_LINE";
					i=$(( i + 1 ));;
				(*)				# handle everything else as a first character of backup number
					echo -n $key; # print the silently read key on the prompt
					read to_restore;
					to_restore="$key$to_restore";;
			esac
			echo -n "$DEF_C"
		else
			i=$(( i + 1 ));
		fi
	done
	if [ ! -z "$back[to_restore]" ]; then
		files=( $(find $RM_BACKUP_DIR/$back[to_restore] -type f) )
		if [ ! -z "$files" ]; then
			for f in $files; do echo $f; done | command sed -r -e "s|$RM_BACKUP_DIR/$back[to_restore]||g" -e "s|/home/$USER|~|g"
                read -q "?Restore ? (Y/n): " && cp --backup=t -R ${RM_BACKUP_DIR/$back[to_restore]/*(:A)} / # create file.~1~ if file already exists
			echo;
		else
			echo "No such back"
		fi
	else
		echo "No such back"
	fi
}


function ft()					# find arg1 in all files from arg2 or .
{
	command find ${2:=.} -type f -exec grep --color=always -InH -e "$1" {} +; # I (ignore binary) n (line number) H (print fn each line)
}


function xtrace()				# debug cmd line with xtrace
{
	set -x;
	$@
}

function title()				# set the title of the term, or toggle the title updating if no args
{
	if [ "$#" -ne "0" ]; then
		print -Pn "\e]2;$@\a"
		UPDATE_TERM_TITLE=""
	else
		if [ -z "$UPDATE_TERM_TITLE" ]; then
			UPDATE_TERM_TITLE="X"
		else
			print -Pn "\e]2;\a"
			UPDATE_TERM_TITLE=""
		fi
	fi
}

function loadconf()				# load a visual config
{
	case "$1" in
		(lite)					# faster, lighter
			UPDATE_TERM_TITLE="";
			UPDATE_CLOCK="";
			setprompt lite;
			;;
		(static)				# nicer, cooler, but without clock update nor title update
			UPDATE_TERM_TITLE="";
			UPDATE_CLOCK="";
			setprompt complete;
			;;
		(complete|*)			# nicer, cooler
			UPDATE_TERM_TITLE="X";
			UPDATE_CLOCK="X";
			setprompt complete;
			;;
	esac
}

function uc()					# remove all? color escape chars
{
	if [ $# -eq 0 ]; then
		sed -r "s/\[([0-9]{1,2}(;[0-9]{1,2})?(;[0-9]{1,3})?)?[mGK]//g"
	else
		$@ | sed -r "s/\[([0-9]{1,2}(;[0-9]{1,2})?(;[0-9]{1,3})?)?[mGK]//g"
	fi
}

function hscroll()				# test
{
	local string;
	local -i i=0;
	local key;
	local crel="$(tput cr;tput el)";
	local -i cols="$(tput cols)"
	[ $# -eq 0 ] && return ;
	string="$(cat /dev/zero | tr "\0" " " | head -c $cols)$@";
	trap "tput cnorm; return;" INT
	tput civis;
	while [ $i -le $#string ]; do
		echo -n ${string:$i:$cols};
		read -sk 3 key;
		echo -en "$crel";
		case $(echo "$key" | cat -v) in
			("^[[C")
				i=$(( i - 1 ));;
			("^[[D")
				i=$(( i + 1 ));;
		esac
	done
	tput cnorm;
}

function iter()					# iter elt1 elt2 ... - command -opt1 -opt2 ...
{
	local i;
	local command;
	local sep;
	local elts;

	elts=();
	command=();
	for i in $@; do
		if [ ! -z "$sep" ]; then
			command+="$i";
		elif [ "$i" = "-" ]; then
			sep="-";
		else
			elts+="$i";
		fi
	done
	for i in $elts; do
		eval ${=command//{}/$i};		# perform word split on the array
	done
}

function c()					# simple calculator
{
	echo $(($@));
}

function d2h()					# decimal to hexa
{
	printf "0x%x\n" "$1"
}

function h2d()					# hexa to decimal
{
	echo $((16#$1));
}

function show-aliases()			# list all aliases
{
	local -i pad;

	for k in "${(@k)aliases}"; do
		[ $#k -gt $pad ] && pad=$#k;
	done
	(( pad+=2 ));
	for k in "${(@k)aliases}"; do
		printf "$C_BLUE%-${pad}s$C_GREY->$DEF_C  \"$C_GREEN%s$DEF_C\"\n" "$k" "$aliases[$k]";
	done
}

function mkback()				# create a backup file of . or the specified dir/file
{
	local toback;
	local backfile;

	if [ -e "$1" ] && [ "$1" != "." ] ; then
		toback="$1";
		backfile="$(basename ${1:A})";
	else
		toback=".";
		backfile="$(basename $(pwd))";
	fi
	backfile+="-$(date +%s).back.tar.gz";
	printf "Backing up %s in %s\n" "$toback" "$backfile";
	tar -cf - "$toback"  | pv -F " %b %r - %e  %t" -s "$(du -sb | cut -d"	" -f1 )" | gzip --best > "$backfile";
}

BLOG_FILE="$HOME/.blog"
function blog()					# blog or blog "text" to log it in a file; blog -v to view the logs
{
	if [ "$1" = "-v" ]; then
		[ -f "$BLOG_FILE" ] && less -S "$BLOG_FILE";
	else
		trap "" INT
		date "+%D %T" | tee -a "$BLOG_FILE"
		if [ $# -eq 0 ]; then
			cat >> "$BLOG_FILE"
		else
			echo "$@" >> "$BLOG_FILE"
		fi
		echo -e "\n" >> "$BLOG_FILE"
		trap - INT
	fi
}

function kbd()
{
	case $1 in
		(caps-ctrl)
			setxkbmap -option ctrl:nocaps;; # caps lock is a ctrl key
		(caps-esc)
			setxkbmap -option caps:escape;; # caps lock is an alt key
		(caps-super)
			setxkbmap -option caps:super;; # caps lock is a super key
		(us)
			setxkbmap us;;
		(fr)
			setxkbmap fr;;
	esac
}

function popup()
{
	trap "tput cnorm; tput rc; return;" INT;
	local -i x y;
	local msg;
	x=-1;
	y=-1;
	while getopts "x:y:" opt 2>/dev/null ; do
		case $opt in
			(x) x=$OPTARG;;
			(y) y=$OPTARG;;
			(*) echo "Invalid option" >&2;
				return;;
		esac
	done
	shift $(( $OPTIND - 1 ));
	msg="$*";
	tput civis;
	tput sc;
	tput cup $y $x;
	print "$msg";
	read -sk1;
	tput rc;
	tput cnorm;
}

### LESS USEFUL USER FUNCTIONS ###

function race()					# race between tokens given in parameters
{
	cat /dev/urandom | tr -dc "0-9A-Za-z" | command egrep --line-buffered -ao "$(echo $@ | sed "s/[^A-Za-z0-9]/\|/g")" | nl
}

function work()					# work simulation
{
	clear;
	text="$(cat $(find ~ -type f -name "*.cpp" 2>/dev/null | head -n25) | sed ':a;$!N;$!ba;s/\/\*[^​*]*\*\([^/*​][^*]*\*\|\*\)*\///g')"
	arr=($(echo $text))
	i=0
	cat /dev/zero | head -c $COLUMNS | tr '\0' '='
	while true
	do
		read -sk;
		echo -n ${text[$i]};
		i=$(( i + 1 ))
	done
	echo
}

function hack()					# hollywood hacker cat
{
	tput setaf 2; cat $@ | pv -qL 25
}

function window()				# prints weather info
{
	curl -s "http://www.wunderground.com/q/zmw:00000.37.07156" | grep "og:title" | cut -d\" -f4 | sed 's/&deg;/ degrees/';
}

function useless_fractal()
{
	local lines columns a b p q i pnew;
	clear;
	((columns=COLUMNS-1, lines=LINES-1, colour=0));
	bi=$((3.0/lines));
	ai=$((3.0/columns));
	for ((b=-1.5; b<=1.5; b+=$bi)); do
		for ((a=-2.0; a<=1; a+=$ai)); do
			for ((p=0.0, q=0.0, i=0; p*p+q*q < 4 && i < 32; i++)); do
				((pnew=p*p-q*q+a, q=2*p*q+b, p=pnew));
			done
			echo -n "\\e[4$(( (i/4)%8 ))m ";
			# echo -n "\\e[48;5;$(( ((i/4)%23) + 232 ))m ";
		done
		echo;
	done
}






