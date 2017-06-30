" ┏━┓╻ ╻┏┓ ╻  ┏━┓╻ ╻   ╻ ╻╻┏┳┓
" ┗━┓┣━┫┣┻┓┃  ┣━┫┣━┫   ┃┏┛┃┃┃┃
" ┗━┛╹ ╹┗━┛┗━╸╹ ╹╹ ╹ ╹ ┗┛ ╹╹ ╹
"                           -- by z3bra
" =====================================
"
" A 16 colors scheme that use your terminal colors

set background=dark
if version > 580
    highlight clear
    if exists("g:syntax_on")
        syntax reset
    endif
endif
let g:colors_name="shblah"

" Actual colours and styles.
highlight ColorColumn  cterm=NONE ctermfg=NONE ctermbg=3
highlight Comment      cterm=bold ctermfg=0    ctermbg=NONE
highlight Constant     cterm=bold ctermfg=2    ctermbg=NONE
highlight Cursor       cterm=bold ctermfg=3    ctermbg=NONE
highlight CursorLine   cterm=NONE ctermfg=NONE ctermbg=NONE
highlight DiffAdd      cterm=bold ctermfg=2    ctermbg=NONE
highlight DiffChange   cterm=bold ctermfg=3    ctermbg=NONE
highlight DiffDelete   cterm=bold ctermfg=1    ctermbg=NONE
highlight FoldColumn   cterm=bold ctermfg=0    ctermbg=NONE
highlight Folded       cterm=bold ctermfg=0    ctermbg=NONE
highlight Function     cterm=bold ctermfg=7    ctermbg=NONE
highlight Identifier   cterm=bold ctermfg=1    ctermbg=NONE
highlight IncSearch    cterm=bold ctermfg=5    ctermbg=5
highlight NonText      cterm=bold ctermfg=0    ctermbg=NONE
highlight Normal       cterm=NONE ctermfg=NONE ctermbg=NONE
highlight Pmenu        cterm=NONE ctermfg=0    ctermbg=7
highlight PreProc      cterm=bold ctermfg=3    ctermbg=NONE
highlight Search       cterm=bold ctermfg=7    ctermbg=5
highlight Special      cterm=bold ctermfg=2    ctermbg=NONE
highlight SpecialKey   cterm=NONE ctermfg=2    ctermbg=NONE
highlight Statement    cterm=bold ctermfg=7    ctermbg=NONE
highlight StatusLine   cterm=NONE ctermfg=NONE ctermbg=7
highlight StatusLineNC cterm=NONE ctermfg=NONE ctermbg=7
highlight String       cterm=NONE ctermfg=1    ctermbg=NONE
highlight TabLineSel   cterm=bold ctermfg=7    ctermbg=NONE
highlight Todo         cterm=bold ctermfg=7    ctermbg=1
highlight Type         cterm=NONE ctermfg=3    ctermbg=NONE
highlight VertSplit    cterm=bold ctermfg=0    ctermbg=NONE
highlight Visual       cterm=bold ctermfg=7    ctermbg=3

" General highlighting group links.
highlight! link diffAdded       DiffAdd
highlight! link diffRemoved     DiffDelete
highlight! link diffChanged     DiffChange
highlight! link Title           Normal
highlight! link LineNr          NonText
highlight! link TabLine         StatusLineNC
highlight! link TabLineFill     StatusLineNC
highlight! link VimHiGroup      VimGroup

" Test the actual colorscheme
syn match Comment      "\"__Comment.*"
syn match Constant     "\"__Constant.*"
syn match Cursor       "\"__Cursor.*"
syn match CursorLine   "\"__CursorLine.*"
syn match DiffAdd      "\"__DiffAdd.*"
syn match DiffChange   "\"__DiffChange.*"
syn match DiffDelete   "\"__DiffDelete.*"
syn match Folded       "\"__Folded.*"
syn match Function     "\"__Function.*"
syn match Identifier   "\"__Identifier.*"
syn match IncSearch    "\"__IncSearch.*"
syn match NonText      "\"__NonText.*"
syn match Normal       "\"__Normal.*"
syn match Pmenu        "\"__Pmenu.*"
syn match PreProc      "\"__PreProc.*"
syn match Search       "\"__Search.*"
syn match Special      "\"__Special.*"
syn match SpecialKey   "\"__SpecialKey.*"
syn match Statement    "\"__Statement.*"
syn match StatusLine   "\"__StatusLine.*"
syn match StatusLineNC "\"__StatusLineNC.*"
syn match String       "\"__String.*"
syn match Todo         "\"__Todo.*"
syn match Type         "\"__Type.*"
syn match VertSplit    "\"__VertSplit.*"
syn match Visual       "\"__Visual.*"

"__Comment              /* this is a comment */
"__Constant             var = SHBLAH
"__Cursor               char under the cursor?
"__CursorLine           Line where the cursor is
"__DiffAdd              +line added from file.orig
"__DiffChange           changed from file.org
"__DiffDelete           -line removed from file.orig
"__Folded               +--- 1 line : Folded line ---
"__Function             function sblah()
"__Identifier           Never ran into that actually...
"__IncSearch            Next search term
"__NonText              This is not a text, move on
"__Normal               Typical text goes like this
"__Pmenu                Currently selected menu item
"__PreProc              #define SHBLAH true
"__Search               This is what you're searching for
"__Special              true false NULL SIGTERM
"__SpecialKey           Never ran into that either
"__Statement            if else return for switch
"__StatusLine           Statusline of current windows
"__StatusLineNC         Statusline of other windows
"__String               "Hello, World!"
"__Todo                 TODO: remove todos from source
"__Type                 int float char void unsigned uint32_t
"__VertSplit            :vsplit will only show ' | '
"__Visual               Selected text looks like this
