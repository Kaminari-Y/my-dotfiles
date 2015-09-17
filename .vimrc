"      ___                       ___           ___           ___      
"     /\__\          ___        /\__\         /\  \         /\  \     
"    /:/  /         /\  \      /::|  |       /::\  \       /::\  \    
"   /:/  /          \:\  \    /:|:|  |      /:/\:\  \     /:/\:\  \   
"  /:/__/  ___      /::\__\  /:/|:|__|__   /::\~\:\  \   /:/  \:\  \  
"  |:|  | /\__\  __/:/\/__/ /:/ |::::\__\ /:/\:\ \:\__\ /:/__/ \:\__\ 
"  |:|  |/:/  / /\/:/  /    \/__/~~/:/  / \/_|::\/:/  / \:\  \  \/__/ 
"  |:|__/:/  /  \::/__/           /:/  /     |:|::/  /   \:\  \       
"   \::::/__/    \:\__\          /:/  /      |:|\/__/     \:\  \      
"    ~~~~         \/__/         /:/  /       |:|  |        \:\__\     
"                               \/__/         \|__|         \/__/     

" README:
" For persanl leaning
"

" Startup: {{{1
" Skip initialization for vim-tiny or vim-small
" take account of '-eval'
"if !1 | finish | endif
if 0 | endif

" Use plain vim
" when vim was invoked by 'sudo' command
" or, invoked as 'git difftool'
if exists('$SUDO_USER') || exists('$GIT_DIR')
  finish
endif

" Script variables {{{2
" boolean
let s:true  = 1
let s:false = 0

" platform
let s:is_windows = has('win16') || has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_mac = !s:is_windows && !s:is_cygwin
      \ && (has('mac') || has('macunix') || has('gui_macvim') ||
      \    (!executable('xdg-open') &&
      \    system('uname') =~? '^darwin'))
let s:is_linux = !s:is_mac && has('unix')

let s:vimrc = expand("<sfile>:p")
let $MYVIMRC = s:vimrc"

" NeoBundle path
if s:is_windows
  let $DOTVIM = expand('~/vimfiles')
else
  let $DOTVIM = expand('~/.vim')
endif
let $VIMBUNDLE = $DOTVIM . '/bundle'
let $NEOBUNDLEPATH = $VIMBUNDLE . '/neobundle.vim'

" vimrc management variables
let s:vimrc_plugin_on                  = get(g:, 'vimrc_plugin_on',                  s:true)
let s:vimrc_suggest_neobundleinit      = get(g:, 'vimrc_suggest_neobundleinit',      s:true)
let s:vimrc_goback_to_eof2bof          = get(g:, 'vimrc_goback_to_eof2bof',          s:false)
let s:vimrc_save_window_position       = get(g:, 'vimrc_save_window_position',       s:false)
let s:vimrc_restore_cursor_position    = get(g:, 'vimrc_restore_cursor_position',    s:true)
let s:vimrc_statusline_manually        = get(g:, 'vimrc_statusline_manually',        s:true)
let s:vimrc_add_execute_perm           = get(g:, 'vimrc_add_execute_perm',           s:false)
let s:vimrc_colorize_statusline_insert = get(g:, 'vimrc_colorize_statusline_insert', s:true)
let s:vimrc_manage_rtp_manually        = get(g:, 's:vimrc_manage_rtp_manually',      s:false)
let s:vimrc_auto_cd_file_parentdir     = get(g:, 's:vimrc_auto_cd_file_parentdir',   s:true)
let s:vimrc_ignore_all_settings        = get(g:, 's:vimrc_ignore_all_settings',      s:false)

" if s:vimrc_manage_rtp_manually is s:true, s:vimrc_plugin_on is disabled.
let s:vimrc_plugin_on = s:vimrc_manage_rtp_manually == s:true ? s:false : s:vimrc_plugin_on

" nil variables
" Usage:
" if exists('s:vimrc_nil_dummy_variables')
"   execute ...
" This variable is used to disable the feature intentionally.
unlet! s:vimrc_nil_dummy_variables

function! s:vimrc_environment()
  let env = {}

  let env.is_starting = has('vim_starting')
  let env.is_gui = has('gui_running')
  let env.hostname = substitute(hostname(), '[^\w.]', '', '')

  if s:is_windows
    let vimpath = expand('~/vimfiles')
  else
    let vimpath = expand('~/.vim')
  endif
  let vimbundle = vimpath . '/bundle'
  let neobundlepath = vimbundle . '/neobundle.vim'

  let env.path = {
    \ 'vim':       vimpath,
    \ 'bundle':    vimbundle,
    \ 'neobundle': neobundlepath,
  \ }

  let env.support = {
    \ 'ag':        executable('ag'),
    \ 'osascript': executable('osascript'),
  \ }

  let env.is_tabpage = (&showtabline == 1 && tabpagenr('$') >= 2)
              \ || (&showtabline == 2 && tabpagenr('$') >= 1)
  return env
endfunction

" s:env is an environment variable in vimrc
let s:env = s:vimrc_environment()

" Depelopment for Vim plugin {{{2
if len(findfile("Vimpfile", ".;")) > 0
  let s:vimrc_plugin_on = s:false
  set runtimepath&
  execute "set runtimepath+=" . s:cwd
  execute "set runtimepath+=" . s:cwd . "/.vimp"
  for s:plugin in split(glob(s:cwd . "/.vimp/*"), '\n')
    execute 'set runtimepath+=' . s:plugin
  endfor
endif

" NeoBundle: {{{1
" Next generation Vim package manager settings.
" Use the NeoBundle (if installed and found on the default search runtimepath).
" If it is not installed, suggest executing ':NeoBundleInit' command.
" The ':NeoBundleInit' allows us to initialize all about NeoBundle.
" TODO: 
"   - neobundle#tap
"   - TOML
"   - NeoBundleInit TEST
"==============================================================================

" Add neobundle to runtimepath.
if has('vim_starting') && isdirectory($NEOBUNDLEPATH)
  if s:vimrc_plugin_on == s:true
    set runtimepath+=$NEOBUNDLEPATH
  endif
endif

" neobundle {{{
if stridx(&runtimepath, $NEOBUNDLEPATH) != -1
  let g:neobundle#enable_tail_path = 1
  let g:neobundle#default_options = {
        \ 'same' : { 'stay_same' : 1, 'overwrite' : 0 },
        \ '_' : { 'overwrite' : 0 },
        \ }
  "call neobundle#rc($VIMBUNDLE)
  call neobundle#begin($VIMBUNDLE)

  " Taking care of NeoBundle by itself
  NeoBundleFetch 'Shougo/neobundle.vim'

  " NeoBundle List
  NeoBundle 'Shougo/unite.vim'
  NeoBundle 'Shougo/vimproc'

  if has('lua') && v:version >= 703
    NeoBundleLazy 'Shougo/neocomplete.vim'
  else
    NeoBundleLazy 'Shougo/neocomplcache.vim'
  endif

  NeoBundle 'Shougo/unite-outline'
  NeoBundle 'Shougo/unite-help'
  "NeoBundle 'Shougo/neomru.vim'
  "NeoBundle 'Shougo/vimfiler'
  "NeoBundle 'Shougo/vimshell'
  "NeoBundle 'Shougo/neosnippet'
  "NeoBundle 'Shougo/neosnippet-snippets'
  "NeoBundle 'glidenote/memolist.vim'
  "NeoBundle 'severin-lemaignan/vim-minimap'
  "NeoBundle 'thinca/vim-scouter'
  "NeoBundle 'thinca/vim-ref'
  "NeoBundle 'thinca/vim-quickrun'
  "NeoBundle 'thinca/vim-unite-history'
  "NeoBundle 'thinca/vim-splash'
  "NeoBundle 'thinca/vim-portal'
  "NeoBundle 'thinca/vim-poslist'
  "NeoBundle 'thinca/vim-tabrecent'
  "NeoBundle 'thinca/vim-qfreplace'
  "NeoBundle 'tyru/nextfile.vim'
  "NeoBundle 'tyru/skk.vim'
  "NeoBundle 'tyru/eskk.vim'
  "NeoBundle 'tyru/open-browser.vim'
  "NeoBundle 'tyru/restart.vim'
  "NeoBundle 'sjl/gundo.vim'
  "NeoBundle 'ujihisa/neco-look'
  "NeoBundle 'ujihisa/unite-colorscheme'
  "NeoBundle 'b4b4r07/vim-vimp'
  "NeoBundle 'b4b4r07/vim-autocdls'
  "NeoBundle 'b4b4r07/mru.vim'
  "NeoBundle 'b4b4r07/vim-shellutils'
  "NeoBundle 'b4b4r07/vim-favdir'
  "NeoBundle 'b4b4r07/vim-ezoe'
  "NeoBundle 'b4b4r07/vim-sunset'
  "NeoBundle 'b4b4r07/vim-pt'
  "NeoBundle has('gui_running') ? 'itchyny/lightline.vim' : 'b4b4r07/vim-buftabs'
  "NeoBundle 'b4b4r07/vim-buftabs'
  "NeoBundle 'itchyny/calendar.vim'
  "NeoBundle 'nathanaelkane/vim-indent-guides'
  NeoBundle 'scrooloose/syntastic'
  NeoBundle 'scrooloose/nerdtree'
  "NeoBundle 'tpope/vim-surround'
  "NeoBundle 'tpope/vim-repeat'
  "NeoBundle 'tpope/vim-markdown'
  "NeoBundle 'tpope/vim-fugitive'
  "NeoBundle 'osyo-manga/vim-anzu'
  "NeoBundle 'cohama/lexima.vim'
  "NeoBundle 'cohama/vim-insert-linenr'
  "NeoBundle 'cohama/agit.vim'
  "NeoBundle 'LeafCage/yankround.vim'
  "NeoBundle 'LeafCage/foldCC.vim'
  "NeoBundle 'junegunn/vim-easy-align'
  "NeoBundle 'mattn/gist-vim'
  "NeoBundle 'mattn/webapi-vim'
  "NeoBundle 'mattn/benchvimrc-vim'
  "NeoBundle 'vim-scripts/Align'
  "NeoBundle 'vim-scripts/DirDiff.vim'
  "NeoBundle 'mattn/excitetranslate-vim'
  "NeoBundle 'yomi322/unite-tweetvim'
  "NeoBundle 'tsukkee/lingr-vim'
  "NeoBundle 'AndrewRadev/switch.vim'
  "NeoBundle 'Yggdroot/indentLine'
  "NeoBundle 'ervandew/supertab'
  "NeoBundle 'vim-scripts/renamer.vim'
  "NeoBundle 'rking/ag.vim'
  "NeoBundle 'mopp/googlesuggest-source.vim'
  "NeoBundle 'mattn/googlesuggest-complete-vim'
  "NeoBundle 'kana/vim-vspec'
  "NeoBundle 'tell-k/vim-browsereload-mac'
  "NeoBundle 'junegunn/vim-emoji'
  "NeoBundle 'majutsushi/tagbar'
  "NeoBundle 'dgryski/vim-godef'
  "NeoBundle 'vim-jp/vim-go-extra'
  "NeoBundle 'google/vim-ft-go'
  "NeoBundle 'ctrlpvim/ctrlp.vim'
  "NeoBundle 'toyamarinyon/hatenablog-vim'
  "NeoBundle 'justinmk/vim-dirvish'
  "NeoBundle 'deris/vim-visualinc'
  "NeoBundle 'hotchpotch/perldoc-vim'
  "NeoBundle 'kchmck/vim-coffee-script'
  "NeoBundle 'elzr/vim-json'
  "NeoBundle 'cespare/vim-toml'
  "NeoBundle 'fatih/vim-go'
  "NeoBundle 'jnwhiteh/vim-golang'
  "NeoBundle 'zaiste/tmux.vim'
  "NeoBundle 'CORDEA/vim-glue'
  "NeoBundle 'dag/vim-fish'
  "NeoBundle 'haya14busa/incsearch.vim'
  "NeoBundle 'rhysd/try-colorscheme.vim'
  "NeoBundle 'rhysd/github-complete.vim'
  "NeoBundle 'junegunn/fzf'
  NeoBundle 'Townk/vim-autoclose'
  NeoBundle 'grep.vim'

  " Japanese help
  NeoBundle 'vim-jp/vimdoc-ja'
  " Vital
  NeoBundle 'vim-jp/vital.vim'

  " Colorschemes
  NeoBundle 'b4b4r07/solarized.vim', { "base" : $HOME."/.vim/colors" }
  NeoBundle 'nanotech/jellybeans.vim', { "base" : $HOME."/.vim/colors" }
  NeoBundle 'tomasr/molokai', { "base" : $HOME."/.vim/colors" }
  NeoBundle 'w0ng/vim-hybrid', { "base" : $HOME."/.vim/colors" }
endif



" My Bundles here:
" Refer to |:NeoBundle-examples|.
" Note: You don't set neobundle setting in .gvimrc!
nnoremap <silent><C-e> :NERDTreeToggle<CR>
let NERDTreeShowHidden = 1
call neobundle#end()

" Required:
filetype plugin indent on

let g:syntastic_ruby_checkers = ['rubocop']

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
syntax on
set nocompatible
set number

