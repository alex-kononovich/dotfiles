set nowrap
set textwidth=80
set number
set expandtab
set shiftwidth=2
set noswapfile
map <space> <leader>
nmap <leader>w :w<CR>
nmap <silent><leader>q :q<CR>
autocmd BufReadPost quickfix nmap <buffer> q :q<CR>
nnoremap Y y$
cnoremap <expr> %% expand('%:h').'/'

" open help in right split
cnoreabbrev h vert bo h

" smart case search
set ignorecase
set smartcase

" allow unsaved changes
set hidden

" read custom configurations in .vimrc per folder
set exrc
set secure

set fillchars=fold:—,vert:\│

" config for messages appearing at the bottom
set shortmess=
set shortmess+=a " use abbreviations
set shortmess+=T " truncate long messages
set shortmess+=W " don't show 'written' message

augroup vim
  autocmd!
  " auto reload vimrc
  autocmd BufWritePost vimrc,.vimrc,init.vim source $MYVIMRC
  " K opens help
  autocmd FileType vim set keywordprg=:vert\ bo\ h
augroup END

call plug#begin('~/.vim/plugged')

if has('nvim')
  " Use <C-L> to clear the highlighting of :set hlsearch.
  if maparg('<C-L>', 'n') ==# ''
    nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
  endif

  " Live substitution preview
  set inccommand=split

  " Esc to go back from terminal mode
  tnoremap <Esc> <C-\><C-n>
else
  Plug 'tpope/vim-sensible'
endif

" seamless tmux pane navigation
Plug 'christoomey/vim-tmux-navigator'
let g:tmux_navigator_no_mappings = 1
let g:tmux_navigator_disable_when_zoomed = 1
nnoremap <silent> <C-Left> :TmuxNavigateLeft<CR>
nnoremap <silent> <C-Right> :TmuxNavigateRight<CR>
nnoremap <silent> <C-Down> :TmuxNavigateDown<CR>
nnoremap <silent> <C-Up> :TmuxNavigateUp<CR>
nnoremap <silent> <C-\> :TmuxNavigatePrevious<CR>

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'

" Fuzzy file finder
Plug 'ctrlpvim/ctrlp.vim'
let g:ctrlp_match_current_file=1
let g:ctrlp_user_command='ag %s -l --nocolor -g ""'
let g:ctrlp_working_path_mode=0
let g:ctrlp_extensions=['buffertag']
let g:ctrlp_buffer_func = {
  \ 'enter': 'HideStatusLine',
  \ 'exit': 'RestoreStatusLine'
  \ }

function! HideStatusLine()
  let g:laststatus_last_value=&laststatus
  set laststatus=0
endfunction

function! RestoreStatusLine()
  let &laststatus=g:laststatus_last_value
endfunction

nmap <silent><leader>o :CtrlP<CR>
" nmap <silent><leader>T :CtrlPBufTag<CR>
nmap <silent><leader>b :CtrlPBuffer<CR>

" Don't quit the window when killing buffer
Plug 'qpkorr/vim-bufkill'
let g:BufKillCreateMappings=0
nmap <leader>d :BD<CR>
nmap <leader>D :bufdo BD<CR>

" Search
Plug 'mileszs/ack.vim', {'on': 'Ack'}
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif
map <leader>f :Ack<space>
map <leader>F :Ack<cword><CR> " search word under cursor

" Git
Plug 'tpope/vim-fugitive'
nmap <leader>gs :Gstatus<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gw :Gwrite<CR>
nmap <leader>gc :Gcommit --verbose<CR>
nmap <leader>gr :Gread<CR>

Plug 'airblade/vim-gitgutter'
let g:gitgutter_map_keys = 0
nmap [c <Plug>GitGutterPrevHunk
nmap ]c <Plug>GitGutterNextHunk

" Gists
Plug 'mattn/webapi-vim', {'on': 'Gist'}
Plug 'mattn/gist-vim', {'on': 'Gist'}
let g:gist_show_privates = 1
let g:gist_post_private = 1
let g:gist_clip_command = 'pbcopy'

" Neomake
if has('nvim')
  Plug 'neomake/neomake'
  nmap <silent><leader>m :update\|Neomake<CR>
  nmap <silent><leader>M :update\|Neomake!<CR>
endif

" Snippets
Plug 'SirVer/ultisnips'
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/ultisnips']

" Autocompletion
" if has('nvim')
  " Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
  " let g:deoplete#enable_at_startup = 1
" endif

" Autoformat
Plug 'sbdchd/neoformat'
let g:neoformat_only_msg_on_error = 1
let g:neoformat_basic_format_trim = 1
let g:neoformat_basic_format_retab = 1
let g:neoformat_try_formatprg = 1
nmap <leader>a :Neoformat<CR>

" Text
au FileType text setlocal wrap linebreak
au FileType gitcommit,markdown setlocal spell

" Autocomplete with dictionary words when spell check is on
set complete+=kspell

" Fish
Plug 'vim-scripts/fish-syntax', {'for': 'fish'}

" Elm
Plug 'elmcast/elm-vim', {'for': 'elm'}
let g:elm_make_show_warnings = 1
let g:elm_classic_highlighting = 1
let g:elm_setup_keybindings = 0
au FileType elm setlocal softtabstop=4 shiftwidth=4
au FileType elm setlocal formatprg=elm-format
au FileType elm nmap <buffer><leader>t :update\|!clear&elm test<CR>
au FileType elm nmap <buffer><leader>m :update\|ElmMakeMain<CR>
au FileType elm nmap <buffer><leader>e :ElmErrorDetail<CR>
au BufWritePost *.elm Neomake

" Haskell
au FileType haskell setlocal formatprg=hindent
au FileType haskell setlocal keywordprg=hoogle\ --info

" Plug 'neovimhaskell/haskell-vim', {'for': 'haskell'}
" let g:haskell_classic_highlighting = 1
" let g:haskell_indent_disable = 1

Plug 'pbrisbin/vim-syntax-shakespeare', {'for': ['haskell', 'hamlet', 'cassius', 'lucius', 'julius']}

Plug 'Twinside/vim-hoogle', {'for': 'haskell'}
let g:hoogle_search_count=20
let g:hoogle_search_buf_size=20

if has('nvim')
  " Plug 'eagletmt/neco-ghc', {'for': 'haskell'}
  " autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc
  let g:neomake_haskell_enabled_makers = ['hdevtools']
endif

" Pug
Plug 'digitaltoad/vim-pug', {'for': 'pug'}
au FileType pug setlocal softtabstop=2 shiftwidth=2
au FileType pug setlocal formatprg=pug-beautifier\ --fillspace\ 2\ --omitdiv

" Javascript (ES6)
Plug 'othree/yajs.vim', { 'for': 'javascript' }
au FileType javascript setlocal softtabstop=2 shiftwidth=2
au FileType javascript setlocal formatprg=js-beautify\ --indent-size\ 2\ --end-with-newline\ --max-preserve-newlines\ 2\ --jslint-happy\ --wrap-line-length\ 80

" HTML
au FileType html,xhtml setlocal softtabstop=2 shiftwidth=2
au FileType html,xhtml setlocal formatprg=html-beautify\ --type\ html\ --indent-size\ 2\ --end-with-newline\ --indent-inner-html\ --max-preserve-newlines\ 2\ --wrap-line-length\ 80

" Colorscheme
Plug 'flskif/terminal16.vim'

call plug#end()

" Must go after plug#end()
colorscheme terminal16
hi! HighlightedyankRegion ctermbg=yellow ctermfg=black
