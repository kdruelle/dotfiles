
setopt cdablevars

# Set BOOKMARKS_FILE if it doesn't exist to the default.
# # Allows for a user-configured BOOKMARKS_FILE.
if [[ -z $BOOKMARKS_FILE ]] ; then
  export BOOKMARKS_FILE="$HOME/.zsh_bookmarks"
fi

# Check if $BOOKMARKS_FILE is a symlink.
if [[ -L $BOOKMARKS_FILE ]]; then
  BOOKMARKS_FILE=$(readlink $BOOKMARKS_FILE)
fi

# Create bookmarks_file it if it doesn't exist
if [[ ! -f $BOOKMARKS_FILE ]]; then
  touch $BOOKMARKS_FILE
fi


function _load_bookmarks(){
    old_IFS=$IFS      # save the field separator
    IFS=$'\n'         # new field separator, the end of line
    for line in $(cat $BOOKMARKS_FILE)
    do
        local markname=$(echo "$line" | cut -d "|" -f 1 | xargs)
        local markpath=$(echo "$line" | cut -d "|" -f 2 | xargs)
        hash -d -- _${markname}=${markpath}/
    done
    IFS=$old_IFS
}

function _list_bookmarks_details(){
    old_IFS=$IFS      # save the field separator
    IFS=$'\n'         # new field separator, the end of line
    for line in $(cat $BOOKMARKS_FILE)
    do
        local markname=$(echo "$line" | cut -d "|" -f 1 | xargs)
        local markpath=$(echo "$line" | cut -d "|" -f 2 | xargs)
        echo "${markname} => ${markpath}"
    done
    IFS=$old_IFS
}

function _list_bookmarks(){
    old_IFS=$IFS      # save the field separator
    IFS=$'\n'         # new field separator, the end of line
    for line in $(cat $BOOKMARKS_FILE)
    do
        local markname=$(echo "$line" | cut -d "|" -f 1 | xargs)
        echo "${markname}"
    done
    IFS=$old_IFS
}

function _bookmark_exists(){
    `cat $BOOKMARKS_FILE | grep -oe "[[:space:]]*test[[:space:]]*"`
    return $?
}

function _get_bookmark_path(){
    return $(cat $BOOKMARKS_FILE | grep -e "[[:space:]]*$1[[:space:]]*" | cut -d "|" -f 2 | xargs)
}

function _add_bookmark(){
    if [ $# = 1 ]; then
        echo "$1 | $(pwd)" >> $BOOKMARKS_FILE
    else
        echo "$1 | $(realpath $2)" >> $BOOKMARKS_FILE
    fi
    _load_bookmarks
}

function _delete_bookmark(){
    for bookmark in $@;
    do
        echo "delete $bookmark from bookmarks"
        sed -i -r "/^[[:space:]]*${bookmark}[[:space:]]*\\|/d" $BOOKMARKS_FILE
    done
}



function bookmark() {
    if (( $# == 0 )); then
        _list_bookmarks_details
        return 0
    fi

    case $1 in
        -a|--add|add)
            shift
            _add_bookmark $@
            ;;
        -d|--delete|delete)
            shift
            _delete_bookmark $@
            ;;
    esac
}


_load_bookmarks



(( $+functions[_bookmark-add] )) ||
_bookmark-add(){
    local curcontext=$curcontext state line ret=1
    declare -A opt_args
    _arguments -w -C -S -s \
        '1:: :_guard "([^-]?#|)" bookmark name'\
        '2:Bookmark Target:_path_files -/' 

#    :: :_guard "([^-]?#|)" message
    case $state in
        help)
            _values 'name' 
    esac

}

(( $+functions[_bookmark-delete] )) ||
_bookmark-delete(){
    local curcontext=$curcontext state line ret=1
    declare -A opt_args
    _arguments -w -C -S -s \
        '(-)*:: :->delete'
    case $state in
        delete)
            _values 'bookmarks' $(_list_bookmarks)
            ;;
    esac
}

_bookmark_commands(){
    local -a main_commands
    main_commands=(
        add:'add new bookmark'
        delete:'delete existing bookmark'
    )
    integer ret=1
    _describe -t main-commands 'commands' main_commands && ret=0
    return ret
}

_bookmark_arg_list=(
    {'(--add)-a','(-a)--add'}'[add new bookmark]:select bookmark:_path_files'
    {'(--delete)-d','(-d)--delete'}'[delete bookmark]:select bookmark:->delete'
    '(-): :->command' \
    '(-)*:: :->option-or-argument'
)

_bookmark(){ 
    local curcontext=$curcontext state line
    declare -A opt_args
    _arguments $_bookmark_arg_list
    case $state in
        command)
            _bookmark_commands #&& ret=0
            ;;
        option-or-argument)
            if (( $+functions[_bookmark-$words[1]] )); then
                _call_function ret _bookmark-$words[1]
            elif zstyle -T :completion:$curcontext: use-fallback; then
                _files && ret=0
            else
                _message 'unknown sub-command'
            fi
            ;;
        delete)
            _values 'bookmarks' $(_list_bookmarks)
            ;;
    esac
}







_bookmark_cd(){
    local curcontext=$curcontext state line
    declare -A opt_args
    _arguments $_bookmark_arg_list
    case $state in
        command)
            _bookmark_commands #&& ret=0
            ;;
        option-or-argument)
            if (( $+functions[_bookmark-$words[1]] )); then
                _call_function ret _bookmark-$words[1]
            elif zstyle -T :completion:$curcontext: use-fallback; then
                _files && ret=0
            else
                _message 'unknown sub-command'
            fi
            ;;
        delete)
            _values 'bookmarks' $(_list_bookmarks)
            ;;
    esac
}

compdef _bookmark bookmark

