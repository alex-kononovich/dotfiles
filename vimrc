" BEHAVIOR
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:vertical_monitor = 1

" automatically reload .vimrc
autocmd! bufwritepost .vimrc source %

" fullscreen help
autocmd FileType help wincmd o " C-w o

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

" save
nmap <leader>s :w<CR>

" close window
nmap <silent><leader>q :q<CR>

" edit vimrc
nmap <silent> <leader>ev :tabedit ~/.vimrc<CR>

" Clear the search highlight in Normal mode
:nnoremap <silent><CR> :nohlsearch<cr>

" Yank from cursor to the end of line. Make it more consistent with D and C
" commands
nnoremap Y y$

" netrw
let g:netrw_banner=0 " no help banner

if g:vertical_monitor == 1
  let g:netrw_preview= 0 " preview in horizontal split
else
  let g:netrw_preview= 1 " preview in vertical split
endif

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

" Fuzzy file finder
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
let g:fzf_layout = { 'up': 15 }
function! s:fzf_statusline()
  setlocal statusline=
endfunction
autocmd! User FzfStatusLine call <SID>fzf_statusline()
nmap <silent><leader>t :Files<CR>
nmap <silent><leader>b :Buffers<CR>

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
" alternate files
map <space><space> <leader><leader>
noremap <leader><leader> :A<CR>

" Comments
Plugin 'tpope/vim-commentary'

" Surround
Plugin 'tpope/vim-surround'

" CoffeeScript
Plugin 'kchmck/vim-coffee-script'

" React JSX for CoffeeScript
Plugin 'mtscout6/vim-cjsx'

" Wrapper for Neovim's :term
Plugin 'kassio/neoterm'

if g:vertical_monitor == 1
  let g:neoterm_position = 'horizontal'
  let g:neoterm_size = 10
else
  let g:neoterm_position = 'vertical'
endif

function! RSpecFocus()
  " Maximize term window
  wincmd o
  " Search for ./app or ./spec filename patters
  let @/='\.\/\(app\|spec\)'
  " Move cursor down
  normal G
endfunction

autocmd! WinEnter *neoterm* call RSpecFocus()


" Universal test runner
Plugin 'janko-m/vim-test'
let g:test#strategy = 'neoterm'
nmap <silent> <leader>rt :update\|TestNearest<CR>
nmap <silent> <leader>rs :update\|TestFile<CR>
nmap <silent> <leader>ra :update\|TestSuite<CR>

" Don't quit the window when killing buffer
Plugin 'qpkorr/vim-bufkill'
let g:BufKillCreateMappings = 0
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
Plugin 'elmcast/elm-vim'
let g:elm_format_autosave = 1
let g:elm_setup_keybindings = 0
let g:elm_classic_highlighting = 1

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

" Bracket mappings
Plugin 'tpope/vim-unimpaired'

" async make
Plugin 'benekastah/neomake'
autocmd BufWritePost * Neomake

" Colorscheme
Plugin 'w0ng/vim-hybrid'
let g:hybrid_custom_term_colors = 1
let g:hybrid_reduced_contrast = 1


" VUNDLE POST-SETUP
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call vundle#end()
filetype plugin indent on


" INTERFACE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax enable

" colorscheme must come after vundle#end() call
" otherwise it won't be loaded
set background=dark
colorscheme hybrid

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬

" show cursor line for easy spotting
" set cursorline

" blend line numbers into background
highlight! link LineNr SpecialKey
highlight! link CursorLineNr SpecialKey

" no different background for SignColum (it's were neomake shows it's warnings)
highlight SignColumn ctermbg=none guibg=none

" don't show status line
set laststatus=0

" pretty fillchars for status line and vertical split
set fillchars=stl:—,stlnc:—,vert:\│

" clear statusline in horizontal split (for whatever reason there has to be a
" at least hightlight group)
set statusline=%#StatusLine#
highlight StatusLine cterm=none ctermbg=none ctermfg=none
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
hi TabLine gui=NONE cterm=none
hi TabLineFill gui=NONE cterm=none
hi TabLineSel guibg=1 guifg=1 gui=bold ctermbg=none ctermfg=12 cterm=bold
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
