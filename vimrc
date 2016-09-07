" BEHAVIOR
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:vertical_monitor = 0

" automatically reload .vimrc
" autocmd! bufwritepost .vimrc source %

" fullscreen help
" autocmd FileType help wincmd o " C-w o

" don't save backup or swp file
set nobackup
set nowritebackup
set noswapfile

" read custom configurations in .vimrc per folder
set exrc
set secure

" search
set hlsearch
set ignorecase
set smartcase
set gdefault

" allows you to have unsaved changes in buffers
" and undo history in them
set hidden

set undolevels=1000

" Intentation settings
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

" netrw
let g:netrw_banner=0 " no help banner

if g:vertical_monitor == 1
  let g:netrw_preview= 0 " preview in horizontal split
else
  let g:netrw_preview= 1 " preview in vertical split
endif



" CUSTOM KEYBINDINGS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <space> <leader>

" save
nmap <leader>s :w<CR>

" close window
nmap <silent><leader>q :q<CR>

" edit vimrc
nmap <silent> <leader>ev :tabedit ~/.vimrc<CR>

" Quit on "q" in quickfix windows
autocmd BufReadPost quickfix nmap <buffer> q :q<CR>

" Yank from cursor to the end of line. Make it more consistent with D and C
" commands
nnoremap Y y$

" use %% as shortcut for current file's directory
cnoremap <expr> %% expand('%:h').'/'


" VUNDLE PRE-SETUP
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
filetype off

" install vundle if not installed
if !isdirectory(expand('~/.vim/bundle/Vundle.vim/.git'))
  !git clone git://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
endif

set runtimepath+=~/.vim/bundle/Vundle.vim
call vundle#begin(expand('~/.vim/bundle/'))

Plugin 'gmarik/Vundle.vim'


" PLUGINS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plugin 'tpope/vim-sensible'

" Fuzzy file finder
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
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
nmap <leader>gc :Gcommit --verbose<CR>

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

" Wrapper for Neovim's :term
if has('nvim')
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
endif


" Universal test runner
Plugin 'janko-m/vim-test'

if has('nvim')
  let g:test#strategy = 'neoterm'
endif

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

" Highlight trailing whitespaces
Plugin 'ntpeters/vim-better-whitespace'
autocmd BufWritePre * StripWhitespace

" Jade syntax
Plugin 'digitaltoad/vim-jade'

" Elm
Plugin 'elmcast/elm-vim'
let g:elm_format_autosave = 1
let g:elm_make_show_warnings = 1
let g:elm_classic_highlighting = 1
let g:elm_setup_keybindings = 0
au FileType elm nmap <buffer><leader>m :update\|ElmMakeMain<CR>
au FileType elm nmap <buffer><leader>s :update\|ElmMake<CR>
au FileType elm nmap <buffer><leader>e :ElmErrorDetail<CR>

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
Plugin 'nelstrom/vim-textobj-rubyblock'

" Elixir
Plugin 'elixir-lang/vim-elixir'

" FocusLost, FocusGained events for terminal vim
Plugin 'tmux-plugins/vim-tmux-focus-events'

" Bracket mappings
Plugin 'tpope/vim-unimpaired'

" async make
if has('nvim')
  Plugin 'benekastah/neomake'
  autocmd BufWritePost * Neomake
endif

" Colorscheme
Plugin 'w0ng/vim-hybrid'
let g:hybrid_custom_term_colors = 1
let g:hybrid_reduced_contrast = 1

" Code snippets
Plugin 'SirVer/ultisnips'

" Tabline and statusline
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
let g:airline_theme='hybrid'
let g:airline_left_sep= ''
let g:airline_right_sep= ''

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#tab_min_count = 2


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

" no different background for SignColum (it's were neomake shows it's warnings)
highlight SignColumn ctermbg=NONE

" pretty fillchars for status line and vertical split
set fillchars=fold:—,vert:\│

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
