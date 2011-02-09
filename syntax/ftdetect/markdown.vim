autocmd BufNewFile,BufRead *.markdown,*.md,*.mdown,*.mkd,*.mkdn,all-notes.txt
      \ if &ft =~# '^\%(conf\|modula2\)$' |
      \   set ft=markdown |
      \ else |
      \   setf markdown |
      \ endif
