" BEHAVIOR
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" automatically reload .vimrc
autocmd! bufwritepost init.vim source %

" don't save backup or swp file
set nobackup
set nowritebackup
set noswapfile

" read custom configurations in .vimrc per folder
set exrc
set secure

" go to the first match as you type
set incsearch
set hlsearch
set ignorecase

" Override the 'ignorecase' if the search pattern contains upper case characters
set smartcase

" g flag by default
set gdefault

" allows you to have unsaved changes in buffers
" and undo history in them
set hidden

set history=1000
set undolevels=1000

" Intentation settings
set autoindent
set smartindent
set expandtab " replace tab with spaces
set tabstop=2 " visual width for tab character
set softtabstop=2 " how many spaces to insert when pressing tab
set shiftwidth=2 " spaces per tab when shifting indentation

set textwidth=80
set nowrap

" automatically create dir on save if not exists
function! s:MkNonExDir(file, buf)
  if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
    let dir=fnamemodify(a:file, ':h')
    if !isdirectory(dir)
      call mkdir(dir, 'p')
    endif
  endif
endfunction
augroup BWCCreateDir
  autocmd!
  autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END

" if a file changes outside vim, reload it without asking
set autoread


" CUSTOM KEYBINDINGS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <space> <leader>

" add blank line above
nmap <silent>- :set paste<CR>m`o<Esc>``:set nopaste<CR>

" add blank line below
nmap <silent>+ :set paste<CR>m`O<Esc>``:set nopaste<CR>

" save
nmap <leader>s :w<CR>

" close window
nmap <silent><leader>q :q<CR>

" edit init.vim and old vimrc
nmap <silent> <leader>ev :tabedit ~/.vimrc\|:vsp ~/.config/nvim/init.vim<CR>

" Clear the search highlight in Normal mode
:nnoremap <silent><CR> :nohlsearch<cr>

" Yank from cursor to the end of line. Make it more consistent with D and C
" commands
nnoremap Y y$

" alternate files
map <space><space> <leader><leader>
noremap <leader><leader> :b#<CR>

" close buffer
nmap <leader>d :bd<CR>

" close all buffers
nmap <leader>D :bufdo bd<CR>

" netrw
let g:netrw_banner=0 " no help banner
let g:netrw_preview= 1 " preview in vertical split

" use %% as shortcut for current file's directory
cnoremap <expr> %% expand('%:h').'/'


" VUNDLE PRE-SETUP
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
filetype off

" install vundle if not installed
if !isdirectory(expand('~/.config/nvim/.vim/bundle/Vundle.vim/.git'))
  !git clone git://github.com/gmarik/Vundle.vim.git ~/.config/nvim/.vim/bundle/Vundle.vim
endif

set runtimepath+=~/.config/nvim/.vim/bundle/Vundle.vim
call vundle#begin(expand('~/.config/nvim/.vim/bundle/'))

Plugin 'gmarik/Vundle.vim'


" PLUGINS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plugin 'frankier/neovim-colors-solarized-truecolor-only'

" Highlight cursor line only on active window
" Plugin 'vim-scripts/CursorLineCurrentWindow'

" Fuzzy file finder
Plugin 'junegunn/fzf'
nmap <silent><leader>t :FZF<CR>

function! s:buflist()
  redir => ls
  silent ls
  redir END
  return split(ls, '\n')
endfunction

function! s:bufopen(e)
  execute 'buffer' matchstr(a:e, '^[ 0-9]*')
endfunction

nnoremap <silent> <leader>b :call fzf#run({
\   'source':  reverse(<sid>buflist()),
\   'sink':    function('<sid>bufopen'),
\   'options': '+m',
\   'down':    len(<sid>buflist()) + 2
\ })<CR>

" Search
Plugin 'rking/ag.vim'
map <leader>f :Ag<space>
map <leader>F :Ag<cword><CR> " search word under cursor

" Git
Plugin 'tpope/vim-fugitive'
nmap <leader>gs :Gstatus<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gw :Gwrite<CR>

" Rails.vim
Plugin 'tpope/vim-rails'

" Comments
Plugin 'tpope/vim-commentary'

" Surround
Plugin 'tpope/vim-surround'

" CoffeeScript
Plugin 'kchmck/vim-coffee-script'

" React JSX for CoffeeScript
Plugin 'mtscout6/vim-cjsx'

" Universal test runner
Plugin 'janko-m/vim-test'

" need to open new tab, othewise neovim will kill current tab for the reasons
" explained here https://github.com/neovim/neovim/issues/3276
function! NeovimTab(cmd) abort
  tabnew | call termopen(a:cmd) | startinsert
endfunction

let test#javascript#jasmine#executable = 'jasmine'
let g:test#custom_strategies = {'neovim_tab': function('NeovimTab')}
let g:test#strategy = 'neovim_tab'

nmap <silent> <leader>rt :update\|TestNearest<CR>
nmap <silent> <leader>rT :update\|TestFile<CR>
nmap <silent> <leader>rl :update\|TestLast<CR>

" Don't quit the window when killing buffer
Plugin 'qpkorr/vim-bufkill'

nmap <leader>d :BD<CR>
nmap <leader>D :bufdo BD<CR>

" Dot command to repeat changes made by plugins
Plugin 'tpope/vim-repeat'

" Autocomplete
Plugin 'ervandew/supertab'

" Slim
Plugin 'onemanstartup/vim-slim'

" Dash.app integration
Plugin 'rizzatti/dash.vim'

" Highlight trailing whitespaces
Plugin 'ntpeters/vim-better-whitespace'
autocmd BufWritePre * StripWhitespace

" Jade syntax
Plugin 'digitaltoad/vim-jade'

" Elm
" Plugin 'lambdatoast/elm.vim'
Plugin 'elmcast/elm-vim'

" Online thesaurus
Plugin 'beloglazov/vim-online-thesaurus'

" Gists
Plugin 'mattn/webapi-vim'
Plugin 'mattn/gist-vim'
let g:gist_show_privates = 1
let g:gist_post_private = 1
let g:gist_clip_command = 'pbcopy'

" Ruby text objects
Plugin 'kana/vim-textobj-user' " textobj-ruby dependency
runtime macros/matchit.vim " textobj-rubyblock dependency
Plugin 'nelstrom/vim-textobj-rubyblock'

" Elixir
Plugin 'elixir-lang/vim-elixir'

" FocusLost, FocusGained events for terminal vim
Plugin 'tmux-plugins/vim-tmux-focus-events'



" VUNDLE POST-SETUP
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call vundle#end()
filetype plugin indent on


" INTERFACE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax enable

" low visibility to special characters
let g:solarized_visibility='low'
set background=light

" colorscheme must come after vundle#end() call
" otherwise it won't be loaded
colorscheme solarized

" don't show current mode - we have cursor shape for that
" and mode takes one extra line at the bottom, which can't be reused
set noshowmode

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬

" show cursor line for easy spotting
" set cursorline

" show line numbers
set number

" blend line numbers into background
highlight! link LineNr SpecialKey
highlight! link CursorLineNr SpecialKey

" don't show status line
set laststatus=0

" pretty fillchars for status line and vertical split
set fillchars=stl:—,stlnc:—,vert:\│

" clear statusline in horizontal split (for whatever reason there has to be a
" at least hightlight group)
set statusline=%#StatusLine#

" vertical split line
highlight clear StatusLine
highlight clear VertSplit

" tabline
function! Tabline()
  let s = ''
  for i in range(tabpagenr('$'))
    let tab = i + 1
    let winnr = tabpagewinnr(tab)
    let buflist = tabpagebuflist(tab)
    let bufnr = buflist[winnr - 1]
    let bufname = bufname(bufnr)
    let bufmodified = getbufvar(bufnr, "&mod")
    let filename = (bufname != '' ? fnamemodify(bufname, ':t') : 'No Name')

    let s .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')

    if bufmodified
      let s .= ' *'
    endif

    let s .= ' '. filename . ' %#TabLineFill#'

  endfor

  let s .= '%#TabLineFill#'
  return s
endfunction
hi TabLine gui=NONE
hi TabLineFill gui=NONE
hi TabLineSel guibg=1 guifg=1 gui=bold
set tabline=%!Tabline()

" config for messages appearing at the bottom
set shortmess=
set shortmess+=a " use abbreviations
set shortmess+=T " truncate long messages
set shortmess+=W " don't show 'written' message
set shortmess+=I " no intro

set winheight=5
set winminheight=5
set winwidth=80
set winminwidth=50

if has('nvim')
  let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
