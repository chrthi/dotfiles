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
  call minpac#add('vim-airline/vim-airline')
  call minpac#add('vim-airline/vim-airline-themes')
  " Language servers in general
  call minpac#add('neoclide/coc.nvim', {'branch': 'release'})
  " git
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('neoclide/coc-git', {'do': 'silent !(yarnpkg install --frozen-lockfile)'})
  " C/C++
  call minpac#add('clangd/coc-clangd', {'type': 'opt', 'do': 'silent !(yarnpkg install --frozen-lockfile)'})
  " Python
  call minpac#add('fannheyward/coc-pyright', {'type': 'opt', 'do': 'silent !(yarnpkg install --frozen-lockfile)' })
  " LaTeX
  call minpac#add('fannheyward/coc-texlab', {'type': 'opt', 'do': 'silent !(yarnpkg install --frozen-lockfile)'})
  " Yocto bitbake
  call minpac#add('kergoth/vim-bitbake')
endfunction

command! PackUpdate source $MYVIMRC | call PackInit() | call minpac#update()
command! PackClean  source $MYVIMRC | call PackInit() | call minpac#clean()
command! PackStatus packadd minpac | call minpac#init() | call minpac#status()

runtime coc.vim
