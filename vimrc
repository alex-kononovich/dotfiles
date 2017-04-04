set nowrap
set textwidth=80
set expandtab
set shiftwidth=4
set noswapfile
map <space> <leader>
nmap <leader>w :w<CR>
nmap <silent><leader>q :q<CR>
autocmd BufReadPost quickfix nmap <buffer> q :q<CR>
nnoremap Y y$
cnoremap <expr> %% expand('%:h').'/'

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

call plug#begin('~/.vim/plugged')

" Colorscheme
Plug 'w0ng/vim-hybrid'
let g:hybrid_custom_term_colors=1
let g:hybrid_reduced_contrast=1
set background=dark
" Make statusline a bit easier on the eyes
highlight StatusLine cterm=bold ctermfg=15 ctermbg=8 gui=bold

if has('nvim')
  " Use <C-L> to clear the highlighting of :set hlsearch.
  if maparg('<C-L>', 'n') ==# ''
    nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
  endif

  " Esc to go back from terminal mode
  tnoremap <Esc> <C-\><C-n>
else
  Plug 'tpope/vim-sensible'
endif

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'

" Fuzzy file finder
Plug 'ctrlpvim/ctrlp.vim'
let g:ctrlp_user_command='ag %s -l --nocolor -g ""'
let g:ctrlp_working_path_mode=0
let g:ctrlp_extensions=['buffertag']
nmap <silent><leader>o :CtrlP<CR>
" nmap <silent><leader>T :CtrlPBufTag<CR>
nmap <silent><leader>b :CtrlPBuffer<CR>

" Highlight trailing whitespaces
Plug 'ntpeters/vim-better-whitespace'
autocmd BufWritePre * StripWhitespace

" Don't quit the window when killing buffer
Plug 'qpkorr/vim-bufkill'
let g:BufKillCreateMappings=0
nmap <leader>d :BD<CR>
nmap <leader>D :bufdo BD<CR>

Plug 'vim-scripts/Align', {'on': 'Align'}

" Search
Plug 'rking/ag.vim', {'on': 'Ag'}
map <leader>f :Ag<space>
map <leader>F :Ag<cword><CR> " search word under cursor

" Git
Plug 'tpope/vim-fugitive'
nmap <leader>gs :Gstatus<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gw :Gwrite<CR>
nmap <leader>gc :Gcommit --verbose<CR>

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
  let g:neomake_haskell_enabled_makers = ['hdevtools']
endif

" Autocompletion
if has('nvim')
  Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
  let g:deoplete#enable_at_startup = 1
endif

" Html
au FileType html setlocal formatprg=html-beautify

" Elm
Plug 'elmcast/elm-vim', {'for': 'elm'}
let g:elm_make_show_warnings = 1
let g:elm_classic_highlighting = 1
let g:elm_setup_keybindings = 0
au FileType elm setlocal softtabstop=4 shiftwidth=4
au FileType elm nmap <buffer><leader>t :update\|!clear&elm test<CR>
au FileType elm nmap <buffer><leader>m :update\|ElmMakeMain<CR>
au FileType elm nmap <buffer><leader>e :ElmErrorDetail<CR>
au FileType elm nmap <buffer><leader>a :update\|ElmFormat<CR>
au BufWritePost *.elm Neomake

" Haskell
if has('nvim')
  Plug 'eagletmt/neco-ghc', {'for': 'haskell'}
  Plug 'neovimhaskell/haskell-vim', {'for': 'haskell'}
  autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc
endif
au FileType haskell setlocal formatprg=stylish-haskell
Plug 'pbrisbin/vim-syntax-shakespeare', {'for': ['haskell', 'hamlet', 'cassius', 'lucius', 'julius']}
Plug 'Twinside/vim-hoogle', {'for': 'haskell'}
let g:hoogle_search_count=20
let g:hoogle_search_buf_size=20

" CoffeeScript
Plug 'kchmck/vim-coffee-script', {'for': 'coffee'}

" Pug
Plug 'digitaltoad/vim-pug', {'for': 'pug'}
au FileType pug setlocal formatprg=pug-beautifier\ -s\ 2

call plug#end()

" Must go after plug#end()
colorscheme hybrid
highlight SignColumn ctermbg=NONE
highlight NeomakeErrorSignDefault ctermbg=NONE
highlight NeomakeWarningSignDefault ctermbg=NONE
highlight NeomakeMessageSignDefault ctermbg=NONE
highlight NeomakeInfoSignDefault ctermbg=NONE
