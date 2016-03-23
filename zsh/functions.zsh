### USEFUL USER FUNCTIONS ###


function escape()				# escape a string
{
	printf "%q\n" "$@";
}









function xtrace()				# debug cmd line with xtrace
{
	set -x;
	$@
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






