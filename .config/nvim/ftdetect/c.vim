augroup FiletypeC
  autocmd!
  autocmd BufRead,BufNewFile *.h,*.c
        \ if !empty(findfile('.clang-format', expand('%:p:h') . ';')) | let b:format_cmd = "call CocAction('format')"
augroup END
