"
"
"  .vimrc -- my personal VIM configuration
"            see https://github.com/Falkor/dotfiles
"
"  Copyright (c) 2010 Sebastien Varrette <Sebastien.Varrette@uni.lu>
"                http://varrette.gforge.uni.lu
"
"             _
"      __   _(_)_ __ ___  _ __ ___
"      \ \ / / | '_ ` _ \| '__/ __|
"       \ V /| | | | | | | | | (__
"      (_)_/ |_|_| |_| |_|_|  \___|
"
"
" To be reworked... for instance using
"   http://github.com/rtomayko/dotfiles/blob/rtomayko/.vimrc
"
" /etc/vim/vimrc ou ~/.vimrc
" Fichier de configuration de Vim
" Formation Debian GNU/Linux par Alexis de Lattre
" http://www.via.ecp.fr/~alexis/formation-linux/

" ':help options.txt' ou ':help nom_du_paramètre' dans Vim
" pour avoir de l'aide sur les paramètres de ce fichier de configuration

" Avertissement par flash (visual bell) plutôt que par beep


try
    call plug#begin('~/.vim/plugged')

    " IDE
    Plug 'https://github.com/scrooloose/nerdtree'
    "Plug 'https://github.com/jistr/vim-nerdtree-tabs'
    Plug 'https://github.com/Xuyuanp/nerdtree-git-plugin'
    Plug 'https://github.com/octol/vim-cpp-enhanced-highlight'
    Plug 'https://github.com/scrooloose/syntastic'
    Plug 'https://github.com/mbbill/undotree'

    " GIT
    Plug 'https://github.com/bling/vim-airline'
    Plug 'https://github.com/tpope/vim-fugitive'
    Plug 'https://github.com/airblade/vim-gitgutter'

    " colorscheme
    Plug 'https://github.com/chriskempson/base16-vim'
    Plug 'https://github.com/morhetz/gruvbox'
    Plug 'https://github.com/antlypls/vim-colors-codeschool'
    Plug 'https://github.com/altercation/vim-colors-solarized'
    Plug 'https://github.com/w0ng/vim-hybrid'

    " Misc
    Plug 'https://github.com/matze/vim-move'
    Plug 'https://github.com/kana/vim-textobj-user'
    Plug 'https://github.com/rhysd/vim-textobj-anyblock'
    Plug 'https://github.com/ctrlpvim/ctrlp.vim'                             " Search plugin
    Plug 'https://github.com/kshenoy/vim-signature'
    Plug 'https://github.com/jeetsukumaran/vim-buffergator'

    Plug 'https://github.com/luochen1990/rainbow'
    Plug 'https://github.com/itchyny/vim-cursorword'
    Plug 'https://github.com/will133/vim-dirdiff'
    Plug 'https://github.com/vim-scripts/a.vim'
    Plug 'https://github.com/vim-scripts/vim-pad'
    Plug 'https://github.com/godlygeek/tabular'
    Plug 'https://github.com/majutsushi/tagbar'
    Plug 'https://github.com/vim-scripts/mru.vim'
    Plug 'https://github.com/gilgigilgil/anderson.vim'
    Plug 'https://github.com/vim-scripts/Highlight-UnMatched-Brackets'
    Plug 'https://github.com/vim-scripts/Tail-Bundle'

    call plug#end()
catch
endtry




set hidden
set title

" :au BufAdd,BufNewFile * nested tab sball
autocmd TabEnter * silent! lcd %:p:h


" Main

" IDE

"Nerdtree
noremap <C-g>                :NERDTreeToggle<CR>
let g:NERDTreeIndicatorMapCustom = {
        \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ "Unknown"   : "?"
    \ }


" Undotree
noremap <C-u>                          :UndotreeToggle<CR>
let g:undotree_SetFocusWhenToggle      = 1
let g:undotree_WindowLayout            = 4
"let g:undotree_SplitWidth              = 5
set undodir=/tmp/undodir/
set undofile

" Highlight
let g:cpp_class_scope_highlight = 1
let g:cpp_experimental_template_highlight = 1



" Git

" Airline
let g:airline#extensions#branche#enabled = 1
let g:airline#extensions#hunks#enabled = 1

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = '%{getcwd()}:h:t'



" MISC

" Move
let g:move_key_modifier = 'C'

" Buffergator
noremap <C-b>                          :BuffergatorToggle<CR>
let g:buffergator_autoupdate = 0
let g:buffergator_display_regime = "filepath"
let g:buffergator_autodismiss_on_select = 1
let g:buffergator_suppress_keymaps = 0
let g:buffergator_viewport_split_policy = "B"


noremap <C-l>                            :CtrlPBuffer<CR>

" Numéros de ligne
set nu

" Encoding
set enc=utf-8

" Tabs
set tabstop=4 shiftwidth=4 expandtab

set list listchars=tab:»·,trail:· ",eol:¶

set pastetoggle=<F2>

" Active la coloration syntaxique
syntax on
" Utiliser le jeu de couleurs standard
" colorscheme default
colorscheme default

" Affiche la position du curseur 'ligne,colonne'
set ruler
" Affiche une barre de status en bas de l'écran
set laststatus=2
" Contenu de la barre de status
set statusline=%<%f%h%m%r%=%l,%c\ %P

" Largeur maxi du texte inséré
" '72' permet de wrapper automatiquement à 72 caractères
" '0' désactive la fonction
set textwidth=0

" Wrappe à 72 caractères avec la touche '#'
map # {v}! par 72
" Wrappe et justifie à 72 caractères avec la touche '@'
map @ {v}! par 72j

" Ne pas assurer la compatibilité avec l'ancien Vi
set nocompatible
" Nombre de colonnes
"set columns=80
" Nombre de commandes dans l'historique
set history=50
" Options du fichier ~/.viminfo
set viminfo='20,\"50
" Active la touche Backspace
set backspace=2
" Autorise le passage d'une ligne à l'autre avec les flèches gauche et droite
set whichwrap=<,>,[,]
" Garde toujours une ligne visible à l'écran au dessus du curseur
set scrolloff=1
" Affiche les commandes dans la barre de status
set showcmd
" Affiche la paire de parenthèses
set showmatch
" Essaye de garder le curseur dans la même colonne quand on change de ligne
set nostartofline
" Option de la complétion automatique
set wildmode=list:full
" Par défaut, ne garde pas l'indentation de la ligne précédente
" quand on commence une nouvelle ligne
set noautoindent
" Options d'indentation pour un fichier C
set cinoptions=(0

" xterm-debian est un terminal couleur
if &term =~ "xterm-debian" || &term =~ "xterm-xfree86"
    set t_Co=16
    set t_Sf=^[[3%dm
    set t_Sb=^[[4%dm
endif

" Quand on fait de la programmation, on veut qu'il n'y ait jamais de
" vraies tabulations insérées mais seulement 4 espaces
autocmd BufNewfile,BufRead *.c set expandtab
autocmd BufNewfile,BufRead *.c set tabstop=4
autocmd BufNewfile,BufRead *.h set expandtab
autocmd BufNewfile,BufRead *.h set tabstop=4
autocmd BufNewfile,BufRead *.cpp set expandtab
autocmd BufNewfile,BufRead *.cpp set tabstop=4

" Décommentez les 2 lignes suivantes si vous voulez avoir les tabulations et
" les espaces marqués en caractères bleus
"set list
"set listchars=tab:>-,trail:-

" Les recherches ne sont pas 'case sensitives'
set ignorecase
" Mettre en surligné les expressions recherchées
set hlsearch

" Fichier d'aide
set helpfile=$VIMRUNTIME/doc/help.txt.gz

" Le découpage des folders se base sur l'indentation
set foldmethod=indent
" 12 niveaux d'indentation par défaut pour les folders
set foldlevel=12

" Police de caractère pour Gvim qui supporte le symbole euro
set guifont=-misc-fixed-medium-r-semicondensed-*-*-111-75-75-c-*-iso8859-15


set wildmenu
set wildmode=longest:full,full

" Resize
noremap <S-right> :vertical resize +5<CR>
noremap <S-left> :vertical resize -5<CR>
noremap <S-up> 5<C-w>+
noremap <S-down> 5<C-w>-



" Switch
noremap <C-Up>              <C-w><Up>
noremap <C-Down>            <C-w><Down>
noremap <C-Left>            <C-w><Left>
noremap <C-Right>           <C-w><Right>
noremap <Tab>            :tabprevious<CR>
noremap <S-Tab>           :tabnext<CR>

nnoremap t <C-]>
nnoremap <S-t> <C-t>
nmap <leader>t :term<cr>
inoremap {<CR>    {}<Left><cr><cr><up><tab>
inoremap {}    {}<Left>
inoremap {};    {};<Left><Left><cr><cr><up><tab>
inoremap {}<CR>    {}<Left><cr><cr><up><tab>
inoremap ''    ''<Left>
inoremap ""    ""<Left>
inoremap ()    ()<Left>
inoremap []    []<Left>
inoremap <>    <><Left>
inoremap <C-a>    <Esc><S-i>
inoremap <C-e>    <Esc><S-a>
inoremap <M-left>    20z<left>
inoremap <C-e>    <Esc><S-a>
inoremap hh <C-o>:stopinsert<CR>:echo<CR>

cnoremap hh <Esc>
noremap <C-f>   /
noremap ;     :
noremap gg=G        gg=G''
noremap <M-left>    20z<left>
noremap <M-right>    20z<right>
noremap <leader>k  :m--<CR>
noremap <leader>j  :m+<CR>

noremap <C-A>            gI
noremap <C-a>            0i
noremap <C-e>            $a
noremap <Space><Space>        :tabedit ~/.vimrc<CR>

noremap <S-e>                b
noremap <Space><Space>        :tabedit ~/.vimrc<CR>

noremap <S-z>                :set fdm=syntax<CR>zR
nnoremap <space>            :nohlsearch<CR>


vnoremap <Tab>                >
vnoremap <S-Tab>            <

inoremap <C-k>    <Up>
inoremap <C-j>    <Down>
inoremap <C-h>    <Left>
inoremap <C-l>    <Right>


"cnoremap <C-h>    <Left>
"cnoremap <C-l>    <Right>
"cnoremap <C-j>    <Down>
"cnoremap <C-k>    <Up>

" inoremap <C-u>                <Esc><C-r>
" noremap <C-u>                <C-r>

inoremap <C-s>        <Esc>:w<CR><insert><Right>
noremap <silent>            <C-s>    :w<CR>
noremap <silent>            <C-q>    :q<CR>
noremap <C-x><C-w>        :execute ToggleLineWrap()<CR>''
noremap <C-x><C-r>        :so $MYVIMRC<CR>

noremap <C-x><S-s>  :w !sudo tee %<CR>L<CR>





" highlight Normal ctermbg=darkblue
" colorscheme gruvbox
colorscheme hybrid
set background=dark
highlight LineNr ctermfg=darkgrey ctermbg=bg

