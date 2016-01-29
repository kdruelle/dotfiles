

GB_C="%F{208}"                  # git branch color



# check if pwd is a git repo
function check_git_repo()		
{
	git rev-parse > /dev/null 2>&1 && REPO=1 || REPO=0
}

function set_git_branch()
{
	if [ $REPO -eq 1 ]; then		# if in git repo, get git infos
		GIT_BRANCH="$(git branch | grep \* | cut -d\  -f2-)";
	else
		GIT_BRANCH="";
	fi
}

function set_git_char()			# set the $GET_GIT_CHAR variable for the prompt
{
	if [ $REPO -eq 1 ];		# if in git repo, get git infos
	then
		local STATUS
		STATUS=$(git status 2> /dev/null)
		if [[ $STATUS =~ "Changes not staged" ]];
		then GET_GIT="%F{196}+"	# if git diff, wip
		else
			if [[ $STATUS =~ "Changes to be committed" ]];
			then GET_GIT="%F{214}+" # changes added
			else
				if [[ $STATUS =~ "is ahead" ]];
				then GET_GIT="%F{46}+" # changes commited
				else GET_GIT="%F{46}=" # changes pushed
				fi
			fi
		fi
	else
		GET_GIT="%F{240}o"		# not in git repo
	fi
}





