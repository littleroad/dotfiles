" 去除vi兼容
set nocompatible

" 打开高亮
syntax on

" Color scheme
"colorscheme kolor
set background=dark
"set columns=80
"set ruler

" 显示行号
set number
set noswapfile
set autowrite

" 不将=包括为文件名
set isfname-==

set modeline

set mouse=a
" Code folding
set nofoldenable
set foldnestmax=10
set foldlevel=0
"set foldmethod=indent
set foldmethod=syntax
"set foldenable

" 设置缩进为8个空格
set tabstop=8
set noexpandtab

" 文件编码与格式
set fileencodings=utf-8,gb18030,gbk
set fileformats=unix,dos
filetype plugin indent on

set wrap "自动换行
set wrapmargin=0
set linebreak
set hlsearch "高亮显示结果
set incsearch "在输入要搜索的文字时，vim会实时匹配

autocmd FileType python setlocal expandtab shiftround smartindent autoindent tabstop=8 shiftwidth=4 softtabstop=4
autocmd FileType c setlocal noexpandtab shiftround autoindent cindent tabstop=8

let mapleader = ","
inoremap jj <ESC>

" taglist
if filereadable("tags")
    set tags+=tags
endif
let Tlist_Ctags_Cmd = '/usr/bin/ctags'
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_Exit_OnlyWindow = 1

map tt :TlistToggle<cr>

if executable('clangd')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd', '--header-insertion-decorators=false']},
        \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
        \ })
endif

autocmd Filetype c,h nnoremap <buffer> <silent> <c-]> :LspDefinition<cr>

" vim-go
let g:go_highlight_types = 1
" let g:go_highlight_structs = 1
" let g:go_highlight_interfaces = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
" let g:go_highlight_methods = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1

let g:go_auto_sameids = 1
let g:go_auto_type_info = 1

autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4

au Filetype go nnoremap <leader>v :vsp <CR>:exe "GoDef" <CR>
au Filetype go nnoremap <leader>s :sp <CR>:exe "GoDef"<CR>
au Filetype go nnoremap <leader>t :tab split <CR>:exe "GoDef"<CR>
au Filetype go nnoremap <leader>d :exe "GoDescribe" <CR>
