""
" Stephen Mann
" January 2011
"
" Treat a markdown file like an outline.
"
" Goals: as few features and mappings as I can live with.
"

" create "toggle fold" shortcut
nmap <Tab> za
nmap <S-Tab> zA

" simplify text displayed on fold
set foldtext=GetFoldText()
function! GetFoldText()
  return getline(v:foldstart) . "  "
endfunction

" Provide "forced validation" of headers on save.
"
" There are two conditions.
"
" 1. Replace multiple carriage returns before a header with a
"    single carrige return
"
" 2. Whenever there's a non-whitespace (\S) character in
"    the line before a header (^\W*#), add a blank line before the
"    header.
"
" Note: backslashes had to be doubly escaped.
"
au bufwrite *.md,all-notes.txt %s/^\s*$\n\(^\s*$\n\)\+\(\W*#.*\)/\r\2/e
au bufwrite *.md,all-notes.txt g/\S\n^\W*#/norm o

" Set the fold levels based on headers.
"
" Created by Jeromy Anglim
"     (source: http://stackoverflow.com/questions/3828606/vim-markdown-folding)
function! MarkdownLevel()
    if getline(v:lnum) =~ '^# .*$'
        return ">1"
    endif
    if getline(v:lnum) =~ '^## .*$'
        return ">2"
    endif
    if getline(v:lnum) =~ '^### .*$'
        return ">3"
    endif
    if getline(v:lnum) =~ '^#### .*$'
        return ">4"
    endif
    if getline(v:lnum) =~ '^##### .*$'
        return ">5"
    endif
    if getline(v:lnum) =~ '^###### .*$'
        return ">6"
    endif
    return "="
endfunction
au BufEnter *.md,all-notes.txt setlocal foldexpr=MarkdownLevel()
au BufEnter *.md,all-notes.txt setlocal foldmethod=expr
