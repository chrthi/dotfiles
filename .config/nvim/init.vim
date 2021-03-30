" vim: set et sw=2 ts=2 ai:

" Created by the dotfiles install script, this defines the features (e.g.
" programming languages) we want to use on this machine.
let g:have_c=0
let g:have_python=0
let g:have_latex=0
let g:have_yocto=0
runtime features.vim

if &compatible
  " `:set nocp` has many side effects. Therefore this should be done
  " only when 'compatible' is set.
  set nocompatible
endif

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

set modeline  " allow per-file settings via modeline
set secure    " disable unsafe commands in local .vimrc files
set scrolloff=5 " scroll the window so we always have cursor +/- n lines
set printoptions=paper:A4
set shell=zsh

" To make your .vimrc reloadable:
"   :function! should be used to define a user function.
"   :command! should be used to define a user command.
"   :augroup! should be used properly to avoid the same autogroups are defined twice.

" Color scheme: solarized dark
syntax enable
set background=dark
" colorscheme solarized8
colorscheme NeoSolarized

" Status line: Powerline doesn't work with neovim, so use airline.
let g:airline_solarized_bg='dark'
let g:airline_theme='solarized'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#whitespace#mixed_indent_algo = 1

" Line numbers: hybrid in normal mode, absolute in insert mode.
set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" LaTeX
let g:tex_flavor = "latex"

runtime plugins.vim
