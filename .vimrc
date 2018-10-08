syntax on
set background=light
inoremap @@ <esc>
set vb nu ai
set noet ci pi sts=0 sw=4 ts=4
map = :wq!<cr>
map - :w!<cr>
map q :q!<cr>
map <tab> :set noai! nocindent! nosmartindent<cr>
map \ :n!<cr>
set shell=bash
let maplocalleader=','        " all my macros start with ,
nmap <LocalLeader>m *
nmap <LocalLeader>x :w!<cr>:!H=%;J=${H\%.eag};/usr/local/bin/eag-compile $J && /usr/local/bin/eagcc ${J}_leftcorner && ( mv ${J}_leftcorner && rm ${J}_leftcorner.c; rm ${J}_leftcorner.o)<cr>

set ruler                     " show the line number on the bar
set more                      " use more prompt
set autoread                  " watch for file CHANGEs
set number                    " line numbers
set hidden
set noautowrite               " don't automagically write on :next
set lazyredraw                " don't redraw when don't have to
set showmode
set showcmd
set nocompatible              " vim, not vi
set autoindent smartindent    " auto/smart indent
set smarttab                  " tab and backspace are smart
set tabstop=2                 " 6 spaces
set shiftwidth=2
set scrolloff=5               " keep at least 5 lines above/below
set sidescrolloff=5           " keep at least 5 lines left/right
set history=200
set backspace=indent,eol,start
set linebreak
set cmdheight=2               " command line two lines high
set undolevels=1000           " 1000 undos
set updatecount=100           " switch every 100 chars
set complete=.,w,b,u,U,t,i,d  " do lots of scanning on tab completion
set ttyfast                   " we have a fast terminal
set noerrorbells              " No error bells please
set fileformats=unix
set ff=unix
filetype on                   " Enable filetype detection
filetype indent on            " Enable filetype-specific indenting
filetype plugin on            " Enable filetype-specific plugins
set wildmode=longest:full
set wildmenu                  " menu has tab completion
set laststatus=2

"  searching
set incsearch                 " incremental search
set ignorecase                " search ignoring case
set hlsearch                  " highlight the search
set showmatch                 " show matching bracket
set diffopt=filler,iwhite     " ignore all whitespace and sync

"  backup
set backup
set backupdir=~/.vim_backup
set viminfo=%100,'100,/100,h,\"500,:100,n~/.viminfo
"set viminfo='100,f1

" spelling
if v:version >= 700
  " Enable spell check for text files
  autocmd BufNewFile,BufRead *.txt setlocal spell spelllang=en
endif

" mappings
" toggle list mode
nmap [ :set list!<cr>
nmap ; :noh<cr>
" toggle paste mode
nmap <LocalLeader>pp :set paste!<cr>
nmap <LocalLeader>c :changes<cr>

autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" Vim syntax file
" Language:     JavaScript
" Maintainer:   Yi Zhao (ZHAOYI) <zzlinux AT hotmail DOT com>
" Last Change:  June 4, 2009
" Version:      0.7.7
" Changes:      Add "undefined" as a type keyword
"
" TODO:
"  - Add the HTML syntax inside the JSDoc

if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'javascript'
endif

"" Drop fold if it set but VIM doesn't support it.
let b:javascript_fold='true'
if version < 600    " Don't support the old version
  unlet! b:javascript_fold
endif

"" dollar sigh is permittd anywhere in an identifier
setlocal iskeyword+=$

syntax sync fromstart

"" JavaScript comments
syntax keyword javaScriptCommentTodo    TODO FIXME XXX TBD contained
syntax region  javaScriptLineComment    start=+\/\/+ end=+$+ keepend contains=javaScriptCommentTodo,@Spell
syntax region  javaScriptLineComment    start=+^\s*\/\/+ skip=+\n\s*\/\/+ end=+$+ keepend contains=javaScriptCommentTodo,@Spell fold
syntax region  javaScriptCvsTag         start="\$\cid:" end="\$" oneline contained
syntax region  javaScriptComment        start="/\*"  end="\*/" contains=javaScriptCommentTodo,javaScriptCvsTag,@Spell fold

"" JSDoc support start
if !exists("javascript_ignore_javaScriptdoc")
  syntax case ignore

  "" syntax coloring for javadoc comments (HTML)
  "syntax include @javaHtml <sfile>:p:h/html.vim
  "unlet b:current_syntax

  syntax region javaScriptDocComment    matchgroup=javaScriptComment start="/\*\*\s*$"  end="\*/" contains=javaScriptDocTags,javaScriptCommentTodo,javaScriptCvsTag,@javaScriptHtml,@Spell fold
  syntax match  javaScriptDocTags       contained "@\(param\|argument\|requires\|exception\|throws\|type\|class\|extends\|see\|link\|member\|module\|method\|title\|namespace\|optional\|default\|base\|file\)\>" nextgroup=javaScriptDocParam,javaScriptDocSeeTag skipwhite
  syntax match  javaScriptDocTags       contained "@\(beta\|deprecated\|description\|fileoverview\|author\|license\|version\|returns\=\|constructor\|private\|protected\|final\|ignore\|addon\|exec\)\>"
  syntax match  javaScriptDocParam      contained "\%(#\|\w\|\.\|:\|\/\)\+"
  syntax region javaScriptDocSeeTag     contained matchgroup=javaScriptDocSeeTag start="{" end="}" contains=javaScriptDocTags

  syntax case match
endif   "" JSDoc end

syntax case match

"" Syntax in the JavaScript code
syntax match   javaScriptSpecial        "\\\d\d\d\|\\x\x\{2\}\|\\u\x\{4\}\|\\."
syntax region  javaScriptStringD        start=+"+  skip=+\\\\\|\\$"+  end=+"+  contains=javaScriptSpecial,@htmlPreproc
syntax region  javaScriptStringS        start=+'+  skip=+\\\\\|\\$'+  end=+'+  contains=javaScriptSpecial,@htmlPreproc
syntax region  javaScriptRegexpString   start=+/\(\*\|/\)\@!+ skip=+\\\\\|\\/+ end=+/[gim]\{,3}+ contains=javaScriptSpecial,@htmlPreproc oneline
syntax match   javaScriptNumber         /\<-\=\d\+L\=\>\|\<0[xX]\x\+\>/
syntax match   javaScriptFloat          /\<-\=\%(\d\+\.\d\+\|\d\+\.\|\.\d\+\)\%([eE][+-]\=\d\+\)\=\>/
syntax match   javaScriptLabel          /\(?\s*\)\@<!\<\w\+\(\s*:\)\@=/

"" JavaScript Prototype
syntax keyword javaScriptPrototype      prototype

"" Programm Keywords
syntax keyword javaScriptSource         import export
syntax keyword javaScriptType           const this undefined var void yield 
syntax keyword javaScriptOperator       delete new in instanceof let typeof
syntax keyword javaScriptBoolean        true false
syntax keyword javaScriptNull           null

"" Statement Keywords
syntax keyword javaScriptConditional    if else
syntax keyword javaScriptRepeat         do while for
syntax keyword javaScriptBranch         break continue switch case default return
syntax keyword javaScriptStatement      try catch throw with finally

syntax keyword javaScriptGlobalObjects  Array Boolean Date Function Infinity JavaArray JavaClass JavaObject JavaPackage Math Number NaN Object Packages RegExp String Undefined java netscape sun

syntax keyword javaScriptExceptions     Error EvalError RangeError ReferenceError SyntaxError TypeError URIError

syntax keyword javaScriptFutureKeys     abstract enum int short boolean export interface static byte extends long super char final native synchronized class float package throws const goto private transient debugger implements protected volatile double import public

"" DOM/HTML/CSS specified things

  " DOM2 Objects
  syntax keyword javaScriptGlobalObjects  DOMImplementation DocumentFragment Document Node NodeList NamedNodeMap CharacterData Attr Element Text Comment CDATASection DocumentType Notation Entity EntityReference ProcessingInstruction
  syntax keyword javaScriptExceptions     DOMException

  " DOM2 CONSTANT
  syntax keyword javaScriptDomErrNo       INDEX_SIZE_ERR DOMSTRING_SIZE_ERR HIERARCHY_REQUEST_ERR WRONG_DOCUMENT_ERR INVALID_CHARACTER_ERR NO_DATA_ALLOWED_ERR NO_MODIFICATION_ALLOWED_ERR NOT_FOUND_ERR NOT_SUPPORTED_ERR INUSE_ATTRIBUTE_ERR INVALID_STATE_ERR SYNTAX_ERR INVALID_MODIFICATION_ERR NAMESPACE_ERR INVALID_ACCESS_ERR
  syntax keyword javaScriptDomNodeConsts  ELEMENT_NODE ATTRIBUTE_NODE TEXT_NODE CDATA_SECTION_NODE ENTITY_REFERENCE_NODE ENTITY_NODE PROCESSING_INSTRUCTION_NODE COMMENT_NODE DOCUMENT_NODE DOCUMENT_TYPE_NODE DOCUMENT_FRAGMENT_NODE NOTATION_NODE

  " HTML events and internal variables
  syntax case ignore
  syntax keyword javaScriptHtmlEvents     onblur onclick oncontextmenu ondblclick onfocus onkeydown onkeypress onkeyup onmousedown onmousemove onmouseout onmouseover onmouseup onresize
  syntax case match

" Follow stuff should be highligh within a special context
" While it can't be handled with context depended with Regex based highlight
" So, turn it off by default
if exists("javascript_enable_domhtmlcss")

    " DOM2 things
    syntax match javaScriptDomElemAttrs     contained /\%(nodeName\|nodeValue\|nodeType\|parentNode\|childNodes\|firstChild\|lastChild\|previousSibling\|nextSibling\|attributes\|ownerDocument\|namespaceURI\|prefix\|localName\|tagName\)\>/
    syntax match javaScriptDomElemFuncs     contained /\%(insertBefore\|replaceChild\|removeChild\|appendChild\|hasChildNodes\|cloneNode\|normalize\|isSupported\|hasAttributes\|getAttribute\|setAttribute\|removeAttribute\|getAttributeNode\|setAttributeNode\|removeAttributeNode\|getElementsByTagName\|getAttributeNS\|setAttributeNS\|removeAttributeNS\|getAttributeNodeNS\|setAttributeNodeNS\|getElementsByTagNameNS\|hasAttribute\|hasAttributeNS\)\>/ nextgroup=javaScriptParen skipwhite
    " HTML things
    syntax match javaScriptHtmlElemAttrs    contained /\%(className\|clientHeight\|clientLeft\|clientTop\|clientWidth\|dir\|id\|innerHTML\|lang\|length\|offsetHeight\|offsetLeft\|offsetParent\|offsetTop\|offsetWidth\|scrollHeight\|scrollLeft\|scrollTop\|scrollWidth\|style\|tabIndex\|title\)\>/
    syntax match javaScriptHtmlElemFuncs    contained /\%(blur\|click\|focus\|scrollIntoView\|addEventListener\|dispatchEvent\|removeEventListener\|item\)\>/ nextgroup=javaScriptParen skipwhite

    " CSS Styles in JavaScript
    syntax keyword javaScriptCssStyles      contained color font fontFamily fontSize fontSizeAdjust fontStretch fontStyle fontVariant fontWeight letterSpacing lineBreak lineHeight quotes rubyAlign rubyOverhang rubyPosition
    syntax keyword javaScriptCssStyles      contained textAlign textAlignLast textAutospace textDecoration textIndent textJustify textJustifyTrim textKashidaSpace textOverflowW6 textShadow textTransform textUnderlinePosition
    syntax keyword javaScriptCssStyles      contained unicodeBidi whiteSpace wordBreak wordSpacing wordWrap writingMode
    syntax keyword javaScriptCssStyles      contained bottom height left position right top width zIndex
    syntax keyword javaScriptCssStyles      contained border borderBottom borderLeft borderRight borderTop borderBottomColor borderLeftColor borderTopColor borderBottomStyle borderLeftStyle borderRightStyle borderTopStyle borderBottomWidth borderLeftWidth borderRightWidth borderTopWidth borderColor borderStyle borderWidth borderCollapse borderSpacing captionSide emptyCells tableLayout
    syntax keyword javaScriptCssStyles      contained margin marginBottom marginLeft marginRight marginTop outline outlineColor outlineStyle outlineWidth padding paddingBottom paddingLeft paddingRight paddingTop
    syntax keyword javaScriptCssStyles      contained listStyle listStyleImage listStylePosition listStyleType
    syntax keyword javaScriptCssStyles      contained background backgroundAttachment backgroundColor backgroundImage gackgroundPosition backgroundPositionX backgroundPositionY backgroundRepeat
    syntax keyword javaScriptCssStyles      contained clear clip clipBottom clipLeft clipRight clipTop content counterIncrement counterReset cssFloat cursor direction display filter layoutGrid layoutGridChar layoutGridLine layoutGridMode layoutGridType
    syntax keyword javaScriptCssStyles      contained marks maxHeight maxWidth minHeight minWidth opacity MozOpacity overflow overflowX overflowY verticalAlign visibility zoom cssText
    syntax keyword javaScriptCssStyles      contained scrollbar3dLightColor scrollbarArrowColor scrollbarBaseColor scrollbarDarkShadowColor scrollbarFaceColor scrollbarHighlightColor scrollbarShadowColor scrollbarTrackColor

    " Highlight ways
    syntax match javaScriptDotNotation      "\." nextgroup=javaScriptPrototype,javaScriptDomElemAttrs,javaScriptDomElemFuncs,javaScriptHtmlElemAttrs,javaScriptHtmlElemFuncs
    syntax match javaScriptDotNotation      "\.style\." nextgroup=javaScriptCssStyles

endif "DOM/HTML/CSS

"" end DOM/HTML/CSS specified things


"" Code blocks
syntax cluster javaScriptAll       contains=javaScriptComment,javaScriptLineComment,javaScriptDocComment,javaScriptStringD,javaScriptStringS,javaScriptRegexpString,javaScriptNumber,javaScriptFloat,javaScriptLabel,javaScriptSource,javaScriptType,javaScriptOperator,javaScriptBoolean,javaScriptNull,javaScriptFunction,javaScriptConditional,javaScriptRepeat,javaScriptBranch,javaScriptStatement,javaScriptGlobalObjects,javaScriptExceptions,javaScriptFutureKeys,javaScriptDomErrNo,javaScriptDomNodeConsts,javaScriptHtmlEvents,javaScriptDotNotation
syntax region  javaScriptBracket   matchgroup=javaScriptBracket transparent start="\[" end="\]" contains=@javaScriptAll,javaScriptParensErrB,javaScriptParensErrC,javaScriptBracket,javaScriptParen,javaScriptBlock,@htmlPreproc
syntax region  javaScriptParen     matchgroup=javaScriptParen   transparent start="("  end=")"  contains=@javaScriptAll,javaScriptParensErrA,javaScriptParensErrC,javaScriptParen,javaScriptBracket,javaScriptBlock,@htmlPreproc
syntax region  javaScriptBlock     matchgroup=javaScriptBlock   transparent start="{"  end="}"  contains=@javaScriptAll,javaScriptParensErrA,javaScriptParensErrB,javaScriptParen,javaScriptBracket,javaScriptBlock,@htmlPreproc 

"" catch errors caused by wrong parenthesis
syntax match   javaScriptParensError    ")\|}\|\]"
syntax match   javaScriptParensErrA     contained "\]"
syntax match   javaScriptParensErrB     contained ")"
syntax match   javaScriptParensErrC     contained "}"

if main_syntax == "javascript"
  syntax sync clear
  syntax sync ccomment javaScriptComment minlines=200
  syntax sync match javaScriptHighlight grouphere javaScriptBlock /{/
endif

"" Fold control
if exists("b:javascript_fold")
    syntax match   javaScriptFunction       /\<function\>/ nextgroup=javaScriptFuncName skipwhite
    syntax match   javaScriptOpAssign       /=\@<!=/ nextgroup=javaScriptFuncBlock skipwhite skipempty
    syntax region  javaScriptFuncName       contained matchgroup=javaScriptFuncName start=/\%(\$\|\w\)*\s*(/ end=/)/ contains=javaScriptLineComment,javaScriptComment nextgroup=javaScriptFuncBlock skipwhite skipempty
    syntax region  javaScriptFuncBlock      contained matchgroup=javaScriptFuncBlock start="{" end="}" contains=@javaScriptAll,javaScriptParensErrA,javaScriptParensErrB,javaScriptParen,javaScriptBracket,javaScriptBlock fold

    if &l:filetype=='javascript' && !&diff
      " Fold setting
      " Redefine the foldtext (to show a JS function outline) and foldlevel
      " only if the entire buffer is JavaScript, but not if JavaScript syntax
      " is embedded in another syntax (e.g. HTML).
      setlocal foldmethod=syntax
      setlocal foldlevel=4
    endif
else
    syntax keyword javaScriptFunction       function
    setlocal foldmethod<
    setlocal foldlevel<
endif

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_javascript_syn_inits")
  if version < 508
    let did_javascript_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif
  HiLink javaScriptComment              Comment
  HiLink javaScriptLineComment          Comment
  HiLink javaScriptDocComment           Comment
  HiLink javaScriptCommentTodo          Todo
  HiLink javaScriptCvsTag               Function
  HiLink javaScriptDocTags              Special
  HiLink javaScriptDocSeeTag            Function
  HiLink javaScriptDocParam             Function
  HiLink javaScriptStringS              String
  HiLink javaScriptStringD              String
  HiLink javaScriptRegexpString         String
  HiLink javaScriptCharacter            Character
  HiLink javaScriptPrototype            Type
  HiLink javaScriptConditional          Conditional
  HiLink javaScriptBranch               Conditional
  HiLink javaScriptRepeat               Repeat
  HiLink javaScriptStatement            Statement
  HiLink javaScriptFunction             Function
  HiLink javaScriptError                Error
  HiLink javaScriptParensError          Error
  HiLink javaScriptParensErrA           Error
  HiLink javaScriptParensErrB           Error
  HiLink javaScriptParensErrC           Error
  HiLink javaScriptOperator             Operator
  HiLink javaScriptType                 Type
  HiLink javaScriptNull                 Type
  HiLink javaScriptNumber               Number
  HiLink javaScriptFloat                Number
  HiLink javaScriptBoolean              Boolean
  HiLink javaScriptLabel                Label
  HiLink javaScriptSpecial              Special
  HiLink javaScriptSource               Special
  HiLink javaScriptGlobalObjects        Special
  HiLink javaScriptExceptions           Special

  HiLink javaScriptDomErrNo             Constant
  HiLink javaScriptDomNodeConsts        Constant
  HiLink javaScriptDomElemAttrs         Label
  HiLink javaScriptDomElemFuncs         PreProc

  HiLink javaScriptHtmlEvents           Special
  HiLink javaScriptHtmlElemAttrs        Label
  HiLink javaScriptHtmlElemFuncs        PreProc

  HiLink javaScriptCssStyles            Label

  delcommand HiLink
endif

" Define the htmlJavaScript for HTML syntax html.vim
"syntax clear htmlJavaScript
"syntax clear javaScriptExpression
syntax cluster  htmlJavaScript contains=@javaScriptAll,javaScriptBracket,javaScriptParen,javaScriptBlock,javaScriptParenError
syntax cluster  javaScriptExpression contains=@javaScriptAll,javaScriptBracket,javaScriptParen,javaScriptBlock,javaScriptParenError,@htmlPreproc

let b:current_syntax = "javascript"
if main_syntax == 'javascript'
  unlet main_syntax
endif
set statusline=%F%m%r%h%w 
set statusline+=[%{strlen(&fenc)?&fenc:&enc}]

set statusline=
set statusline+=%7*\[%n]                                  "buffernr
set statusline+=%1*\ %<%F\                                "File+path
set statusline+=%2*\ %y\                                  "FileType
set statusline+=%3*\ %{''.(&fenc!=''?&fenc:&enc).''}      "Encoding
set statusline+=%3*\ %{(&bomb?\",BOM\":\"\")}\            "Encoding2
set statusline+=%4*\ %{&ff}\                              "FileFormat (dos/unix..) 
set statusline+=%8*\ %=\ row:%l/%L\ (%03p%%)\             "Rownumber/total (%)
set statusline+=%9*\ col:%03c\                            "Colnr
set statusline+=%0*\ \ %m%r%w\ %P\ \                      "Modified? Readonly? Top/bot.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
