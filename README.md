## Installation

Use your favorite plugin manager

Example: [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'kis9a/vim-markdown-textlink'
```

## Configuration

```vim
augroup vim_markdown_textlink
  au BufNewFile,BufReadPost *.md nn <buffer> mi :MarkdownTextlinkInput<CR>
  au BufNewFile,BufReadPost *.md nn <buffer> ml :MarkdownTextlinkReplaceCursorLink<CR>
augroup END
```
