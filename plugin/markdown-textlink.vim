if exists('g:loaded_markdown_textlink') && g:loaded_markdown_textlink
 finish
endif

function! s:promptInput()
  let curline = getline('.')
  echohl MarkdownTextLinkPromptColor
  call inputsave()
  let promptInput=input('Link > ')
  echohl NONE
  call inputrestore()
  call setline('.', curline)
  return promptInput
endfunction

function! s:isValidLink(link)
  if a:link =~# '^\(http\|https\):\/\/.\+'
    return a:link
  else
    return v:null
  endif
endfunction

function! s:cursorLinkBeginPosition()
  let x = getpos('.')[2]
  let cursorAfterLength = len(matchstr(getline('.'), '\v(\f|:)*', x-1))
  let linkLength = len(expand('<cfile>'))
  return (x - (linkLength - cursorAfterLength))
endfunction


function! s:replaceCursorLink(link, textlink)
  let line = getline('.')
  let column = s:cursorLinkBeginPosition()
  let before = column > 1 ? line[:column - 2] : ''
  let after = line[column - 1:]
  let newLine = before . substitute(after, a:link, a:textlink, '')
  call setline('.', newLine)
endfunction

function! s:fetchLinkTitle(link)
  if executable('curl')
    let cmd = 'curl -sL "'. a:link .'" | grep -o "<title>[^<]*" | tail -c+8'
    echo 'Feching link title ...'
    let linkTitle = system(cmd)
    if linkTitle ==# '' || v:shell_error
      return v:null
    else
      return substitute(linkTitle, '\n$', '', '')
    endif
  else
    return v:null
  endif
endfunction

function! s:makeTextLink(title, link)
  return '['. a:title .']('. a:link .')'
endfunction

function! s:insertTextLink(link)
  let line = getline('.')
  let column = col('.')
  let newLine = line[:column - 2] . a:link . line[column - 1:]
  call setline('.', newLine)
endfunction

function! s:markdownTextlinkInput()
  let link = s:promptInput()
  if link ==# ''
    return
  endif
  if s:isValidLink(link) ==# v:null
    echoerr 'Invalid link input'
    return v:null
  endif
  let title = s:fetchLinkTitle(link)
  if title ==# v:null
    echoerr 'Failed fetch link title'
    return v:null
  endif
  call s:insertTextLink(s:makeTextLink(title, link))
endfunction

function! s:markdownTextlinkReplaceCursorLink()
  let link = expand('<cfile>')
  if s:isValidLink(link) ==# v:null
    return v:null
  endif
  let title = s:fetchLinkTitle(link)
  if title ==# v:null
    echoerr 'Failed fetch link title'
    return v:null
  endif
  call s:replaceCursorLink(link, s:makeTextLink(title, link))
endfunction


highlight default link MarkdownTextLinkPromptColor Question
command! MarkdownTextlinkInput call s:markdownTextlinkInput()
command! MarkdownTextlinkReplaceCursorLink call s:markdownTextlinkReplaceCursorLink()

let g:loaded_markdown_textlink = 1
