---
title: "vim plugins I use"
date: 2020-03-02
author: chrsm
description: "The vim plugins that I use"
---

I saw a post on [lobsters][1] that piqued my interest. Peter over at
catonmat.net [made a large list of vim plugins][2] that they use.

It seems like a large amount of plugins - but everyone has their own set of
preferences as to how they work, and I'd wager a guess that they're better at
vim than I'll ever be ;) I'm the kind of guy who presses `j` 15 times much more
often than `ctrl-f` and I don't often use my leader key. `/shrug`

There's a few in the list that I'm looking forward to trying out:

- [markonm/traces.vim][26] - visual feedback of changes via `:s/`. I often
screw this up, so it sounds great.
- [airblade/vim-rooter][27] - change project root to `.git` (or other "known files")
- [a.vim][28] - alternate between `.c` and `.h` easily

I'm going to go from top-to-bottom of my list of plugins rather than
alphabetical - primarily due to laziness.


---------

## Experience-improving plugins

The following plugins enhance the way I use vim, but are not language specific.

### [justinmk/vim-dirvish][3]

`vim-dirvish` is a directory browser for vim. Honestly, that's probably 'nuff
said. I press `-` and walk around the fs.

### [sjl/gundo.vim][4]

`gundo.vim` creates a visual tree of your undo history. Basically, git-esque
history for your in-progress changes.

### [vim-arline/vim-arline][5]

`vim-airline` is a simple tabline for vim. It's not remotely as heavy as the
tablines of old. There's a number of themes and integrations for this.

### [ctrlpvim/ctrlp.vim][6]

Fuzzy path finder for files, buffers, tags, etc. I have this hooked up to `,p`
(for files) and `,b` (for buffers) for ease-of-use.

### [talek/obvious-resize][7]

`talek/obvious-resize` makes resizing splits extremely simple. I have these
mapped to `CTRL-<dir>`. Supposedly works with tmux as well, but I don't use
that functionality.

### [tpope/vim-eunuch][8]

`vim-eunuch` implements UNIX helpers within vim. Generally use this for
`:SudoWrite` and `:SudoEdit`, but `:Rename` is helpful as well.

### [tpope/vim-fugitive][9]

Hands-down the best git integration with vim. I don't want to waste words here,
just check the README and enjoy.

### [tommcdo/vim-fugitive-blame-ext][10]

Extremely simple extension to `vim-fugitive` that shows the first line of
the commit message when exploring with `:Gblame`.

### [gregsexton/gitv][11]

`gitk` for vim (using `vim-fugitive`). No longer maintained, but works well.
Extremely helpful if you don't want to look at git commits separately.

### [Shougo/deoplete.nvim][12]

> Dark powered asynchronous completion framework for neovim/Vim8

Shougo, possibly the most productive vim plugin developer ever - has quite a
history with autocomplete helpers in vim. This is the one I've been using since
switching to neovim. Works well, and that's all I could ask for.

### [rhsyd/committia.vim][13]

Great integration for writing commit messages in vim. Provides a commit message
window, diff window, and git status window.

Set `$EDITOR` to vim and enjoy writing commit messages in vim.

### [chrsm/vim-colors-paramount][24]

My own slight tweak of [owickstrom/vim-colors-paramount][25].


## Language-specific vim plugins

### [autozimu/LanguageClient-neovim][18]

The (IMO) de facto implementation of a language server client in vim.
Supports anything you'd expect from such a client, including go-to-definition,
rename, hover for type info, symbol query, etc.

### [w0rp/ale][16]

LSP-enabled linting plugin. Pretty much every language is supported. It also
supports go-to-definition and find-references.

### [stephpy/vim-yaml][14]

Provides syntax highlighting for yaml. Vim has this by default but it is slow.

### [vim-ruby/vim-ruby][15]

Better ruby integration with vim. I'll probably end up removing this as I don't
have to write ruby anymore :)

### [posva/vim-vue][17]

Syntax highlighting for Vue.js and integrates with ALE.

### [fatih/vim-go][19]

Go support for vim. Updated frequently, provides `gopls` for language client,
as well as other Go-specific utilities.

### [sebdah/vim-delve][20]

Support for the (best) Go debugger, [delve][21].

### [rhysd/vim-clang-format][22]

Implements support for `clang-format` in vim. I use this for C++.

### [rust-lang/rust.vim][23]

Implements rust syntax highlighting and ft detection. Formats via rustfmt.


## ;wq

[1]: https://lobste.rs
[2]: https://catonmat.net/vim-plugins
[3]: https://github.com/justinmk/vim-dirvish
[4]: https://github.com/sjl/gundo.vim
[5]: https://github.com/vim-airline/vim-airline
[6]: https://github.com/ctrlpvim/ctrlp.vim
[7]: https://github.com/talek/obvious-resize
[8]: https://github.com/tpope/vim-eunuch
[9]: https://github.com/tpope/vim-fugitive
[10]: https://github.com/tommcdo/vim-fugitive-blame-ext
[11]: https://github.com/gregsexton/gitv
[12]: https://github.com/Shougo/deoplete.nvim
[13]: https://github.com/rhsyd/committia.vim
[14]: https://github.com/stephpy/vim-yaml
[15]: https://github.com/vim-ruby/vim-ruby
[16]: https://github.com/w0rp/ale
[17]: https://github.com/posva/vim-vue
[18]: https://github.com/autozimu/LanguageClient-neovim
[19]: https://github.com/fatih/vim-go
[20]: https://github.com/sebdah/vim-delve
[21]: https://github.com/go-delve/delve
[22]: https://github.com/rhysd/vim-clang-format
[23]: https://github.com/rust-lang/rust.vim
[24]: https://github.com/chrsm/vim-paramount
[25]: https://github.com/owickstrom/vim-colors-paramount
[26]: https://github.com/markonm/traces.vim
[27]: https://github.com/airblade/vim-rooter
[28]: https://www.vim.org/scripts/script.php?script_id=31
