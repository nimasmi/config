" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2008 Dec 17

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
filetype off " required for Vundle

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif
set background=dark
set ruler
set number
set expandtab
set shiftwidth=4
set softtabstop=4

" experimental fix for shells in :sh
let $UNDER_VIM='Yes, probably'

" Vundle lines below

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'

" My Bundles here:
"
" original repos on github
Bundle 'tpope/vim-fugitive'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}
" vim-scripts repos
Bundle 'L9'
Bundle 'FuzzyFinder'
" non github repos
Bundle 'git://git.wincent.com/command-t.git'
" git gutter
Bundle 'airblade/vim-gitgutter'
" matchit
Bundle 'jwhitley/vim-matchit'
" flake8
Bundle 'nvie/vim-flake8'

filetype plugin indent on     " required!
"
" Brief help
" :bundlelist          - list configured bundles
" :BundleInstall(!)    - install(update) bundles
" :BundleSearch(!) foo - search(or refresh cache first) for foo
" :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle command are not allowed..

" Vim Colors from https://github.com/daylerees/colour-schemes
Bundle "daylerees/colour-schemes", { "rtp": "vim-themes/" }
colorscheme Darkside

" remap leader key
let mapleader=","

" remap : to ;
nnoremap ; :

" define keys to edit and reload .vimrc
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" set buffers to be hidden, not closed
set hidden

set nowrap        " don't wrap lines
set tabstop=4     " a tab is four spaces
set backspace=indent,eol,start
                  " allow backspacing over everything in insert mode
set autoindent    " always set autoindenting on
set copyindent    " copy the previous indentation on autoindenting
set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
set showmatch     " set show matching parenthesis
set ignorecase    " ignore case when searching
set smartcase     " ignore case if search pattern is all lowercase,
                  "    case-sensitive otherwise
set smarttab      " insert tabs on the start of a line according to
                  "    shiftwidth, not tabstop

autocmd BufWritePre *.py normal m`:%s/\s\+$//e``

" ignore certain files for filename completion
set wildignore=*.swp,*.bak,*.pyc

" I'm a git user
set nobackup
set noswapfile

" map <leader>space to clear search highlights
nnoremap <leader><space> :noh<cr>:call clearmatches()<cr>¬

" map n and N to place search results in centre of the screen, also open
" enough folds to make the search results visible
nnoremap n nzzzv
nnoremap N Nzzzv

" Clean trailing whitespace
nnoremap <leader>w mz:%s/\s\+$//<cr>:let @/=''<cr>`z

" highlight anything over 80 columns
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
:match OverLength /\%81v.\+/

" highlight trailing whitespace, (done in a way that future colorscheme
" commands won't countermand it
" :autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
" match trailing whitespace, except when typing at the end of a line
" :match ExtraWhitespace /\s\+\%#\@<!$/
" redraw the gui to highlight when leaving insert mode
" :autocmd InsertLeave * redraw!
" :au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
" :au InsertLeave * match ExtraWhitespace /\s\+$/

" run flake8 whenever a python file is written
" autocmd BufWritePost *.py call Flake8()


" remap escape to the capslock key
