let g:coc_supported = (has('nvim-0.3.2') || has('patch-8.0.1453')) && executable('node')
" minpac needs to run only when changing/updating packages. So put all
" package management in a function to not slow down normal startup.
function! PackInit() abort
  packadd minpac

  call minpac#init()
  " minpac must have {'type': 'opt'} so that it can be loaded with `packadd`.
  call minpac#add('k-takata/minpac', {'type': 'opt'})

  " Solarized color scheme
  call minpac#add('overcache/NeoSolarized')
  " Status bar and theme
  if v:version >= 702
    call minpac#add('vim-airline/vim-airline')
    call minpac#add('vim-airline/vim-airline-themes')
  endif

  " coc.nvim and plugins for it
  if g:coc_supported
    " Language servers in general
    call minpac#add('neoclide/coc.nvim', {'branch': 'release'})
    " git
    call minpac#add('neoclide/coc-git', {'do': 'silent !(yarnpkg install --frozen-lockfile)'})
    " C/C++
    if g:have_c | call minpac#add('clangd/coc-clangd', {'type': 'opt', 'do': 'silent !(yarnpkg install --frozen-lockfile)'}) | endif
    " Python
    if g:have_python | call minpac#add('fannheyward/coc-pyright', {'type': 'opt', 'do': 'silent !(yarnpkg install --frozen-lockfile)' }) | endif
    " LaTeX
    if g:have_latex | call minpac#add('fannheyward/coc-texlab', {'type': 'opt', 'do': 'silent !(yarnpkg install --frozen-lockfile)'}) | endif
  endif

  " git (coc-git is still incomplete)
  call minpac#add('tpope/vim-fugitive')
  " Meson build system
  if g:have_c || g:have_yocto | call minpac#add('igankevich/mesonic') | endif
  " Yocto bitbake
  if g:have_yocto | call minpac#add('kergoth/vim-bitbake') | endif
endfunction

if has('nvim-0.2') || has('patch-8.0.50') " Minimum neovim / vim8 version for minpac
  command! PackUpdate source $MYVIMRC | call PackInit() | call minpac#update()
  command! PackClean  source $MYVIMRC | call PackInit() | call minpac#clean()
  command! PackStatus packadd minpac | call minpac#init() | call minpac#status()
endif

if g:coc_supported | runtime coc.vim | endif
