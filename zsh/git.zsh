
function gitall(){

    local directory=$1

    shift

    for d in $directory/*(/); do
        if [[ ! -d "$d/.git" ]]; then
            continue
        fi
        echo "++++++ $(basename $d)"
        git --git-dir=$d/.git --work-tree=$d $@
        echo "------ $(basename $d)"
    done
}

function gitinfo()
{
    local branch;
    local h;

    [ $# -eq 1 ] && dir=$1 || dir=.

    for d in $dir/*(/); do
        if [ -d "$d/.git" ]; then
            branch="$(git --git-dir=$d/.git --work-tree=$d branch | grep \* | cut -d\  -f2-)";
            h=$(echo $branch | md5sum | cut -d\  -f1 | head -c 2);
            h=$(( 40 + (16#$h % 80) * 2 ));
            changed="$(git --git-dir=$d/.git --work-tree=$d diff --shortstat | grep -Eo '([0-9]+) files? changed.' | grep -Eo '[0-9]+')"
            added="$(git --git-dir=$d/.git --work-tree=$d diff --shortstat | grep -Eo '([0-9]+) insertion' | grep -Eo '[0-9]+')"
            deleted="$(git --git-dir=$d/.git --work-tree=$d diff --shortstat | grep -Eo '([0-9]+) deletion' | grep -Eo '[0-9]+')"
            printf "%-40s: \x1b[38;5;%dm%s\x1b[0m%s (%.6s) \x1b[33m%3d\x1b[0m, \x1b[32m%3d\x1b[0m, \x1b[31m%3d\x1b[0m\n" "$(basename $d)" "$h" "$branch" "$(cat /dev/zero | head -c $(( 15 - $#branch )) | tr '\0' ' ')" "$(git --git-dir=$d/.git rev-parse HEAD)" "$changed" "$added" "$deleted";
        fi
    done;
}

_gitall(){ 
    local curcontext=$curcontext state line
    declare -A opt_args
    _arguments -w -C -S -s \
        '1:Bookmark Target:_path_files -/' \
        '(-)*:: :->option-or-argument'

    case $state in
        option-or-argument)
            service="git"
            _call_function ret _git
            ;;
    esac
}


compdef _gitall gitall



function deploy()
{
    tg;
    failed=();
    success=();
    for f in $@; do
        nice=$f;
        if [ $nice = "." ]; then nice=$(basename $PWD) fi
        tput setaf 5; echo $nice; tput sgr0;
        # (cd $f && cmake . && make && sudo make install;);
        (cd $f && cmake . && make);
        [ $? -ne 0 ] && failed+="$nice" || success+="$nice";
    done
    for f in $success; do
        tput setaf 2;
        echo "$f succeded";
        tput sgr0;
    done
    for f in $failed; do
        tput setaf 1;
        echo "$f failed";
        tput sgr0;
    done
    if [ $#failed -eq 0 ]; then return 0;
    else return 1;
    fi

}

function ddeploy()

{

    tg;

    failed=();

    success=();

    for f in $@; do

        nice=$f;

        if [ $nice = "." ]; then nice=$(basename $PWD) fi

        tput setaf 5; echo $nice; tput sgr0;

        # (cd $f && cmake . -DCMAKE_BUILD_TYPE=Debug && make && sudo make install;);

        (cd $f && cmake . -DCMAKE_BUILD_TYPE=Debug && make);

        [ $? -ne 0 ] && failed+="$nice" || success+="$nice";

    done

    for f in $success; do

        tput setaf 2;

        echo "$f succeded";

        tput sgr0;

    done

    for f in $failed; do

        tput setaf 1;

        echo "$f failed";

        tput sgr0;

    done

    if [ $#failed -eq 0 ]; then return 0;

    else return 1;

    fi

}

alias d="deploy ."

alias dd="ddeploy ."


function _switchbranch()        # current, target
{
    if [ -z "$(git diff)" ]; then
        echo "++++++ No diff";
    else
        echo "++++++ Diff found, stashing...";
        git stash;
    fi
    echo "++++++ $1 -> $2";
    git checkout "$2";
    git pull;

}

dep=(library_logger library_iso8583 library_monitor library_http library-openproto library-cb2a library-ax2a)

function gitsetall(){
    [ $# -eq 0 ] && echo "Usage: $0 dir #OP" >&2

    local target=$2
    local dir=$(readlink -f $1)
    local branch
    local current

    _pwd=$PWD
    cd $dir

    for d in *(/); do

        cd $d;
        echo "++++++ $d"
        if [ -d ".git" ]; then
            echo "++++++ fetching..."
            git fetch
            current=$(git branch | grep \* | cut -d\  -f2- | xargs)
            branch=$(git branch | cut -d\  -f2- | grep -E "$target" | xargs)

            echo "++++++ Current branch: $current";
            echo "++++++ Target branch: $branch";

            if [ "$current" = "$branch" ]; then                 # on est sur la bonne
                echo "++++++ $d already on branch $branch"

            elif [ ! -z "$branch" ]; then                       # on doit aller sur la bonne car elle existe
                _switchbranch "$current" "$branch"
            elif [ "$current" = "develop" ]; then
                echo "++++++ Already on develop"
            elif [ ! -z "$(git branch | cut -d\  -f2- | grep -E "develop")" ]; then # on doit aller sur develop
                _switchbranch "$current" "develop"
            else                                        # on va sur master
                _switchbranch "$current" "master"              
            fi

            echo "\n\n\n";
        fi
        cd - >/dev/null;
    done

    clear;

    echo "++++++ Git stuff done"

    gitinfo $dir

    echo;

    PWD=$_pwd

    echo "++++++ Done"

}





