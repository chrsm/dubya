---
title: "Experimenting with LOVE2D: Part 2 (Dependencies)"
date: "2020-08-24"
author: "chrsm"
---

Earlier this month, I started experimenting with LOVE2D and how I'd develop a
game. There's a lot to take in and I'm really still learning the basics in
the spare time that I have.

One of the things that I'm not a big fan of is that Lua doesn't have a standard
package manager - there's Luarocks, but very few LOVE-related packages actually
have a rockspec. I'm still working out how to include Luarocks packages properly
within LOVE. I found [loverocks][1] and will look into it very soon.

Given that I use git, it follows that I could just use git submodules, but my
experience with them has been frustrating - and not everything I want to use
is actually in git. I want to bundle certain things that aren't source code.
git submodules don't help in this regard.

What I really needed was a "generic dependency manager". I searched for a while,
and found something that seemed like exactly what I wanted: [peru][2].


### Enter... peru

[peru][2] is a dependency manager that can handle git, svn, hg, raw downloads -
pretty much anything you need. It can be further extended by custom plugins,
but I haven't yet had to implement one.

Peru allows pinning to certain revisions or tags, effectively helping push
to reproducible builds. It can also update dependencies automatically for you
with the `reup` command.

One thing that made me _extremely_ happy is how configurable `peru.yaml` is.

For example, I have some `.so` and `.dll` files I want to move into a specific
directory. With peru, I can do this easily:

```yaml
imports:
  # specific to amd64 nix
  lib_64_so: ./

curl module lib_64_so:
  url: https://server.org/release/lib-amd64.tar.gz
  unpack: tar

```

`lib-amd64.tar.gz` includes a README, as well as a LICENSE file. I don't need
the README - but I do need the license. I also don't want to clobber my own
README with this download - or any other dependency. Peru allows this to solve
me - easily.

```yaml
curl module lib_64_so:
  url: https://server.org/release/lib-amd64.tar.gz
  unpack: tar
  drop:
    - README
  move:
    lib64.so: dest/lib64.so
    LICENSE: vendor/libso_64.LICENSE
```

Now I can easily track the license file - in case the project ever goes out -
and move the `.so` directly where I need it.

For curl-based dependencies, you can also specify a hash via the `sha1` field:

```yaml
curl ...:
  sha1: the-hash-i-trust
```

Helps me reconcile downloading dependencies that may change - I _know_ the last
version I knew worked (or trusted).


### git, too!

Peru is really easy to use with git-based dependencies, too, with none of the
git submodule business (directly). Just like curl modules, I can drop some
of the files I don't actually want.

```yaml
imports:
  lualib: ./

git module lualib:
  url: https://server.org/lualib
  drop:
    - README.md
    - main.lua
  move:
    lib.lua: src/thirdparty/lib.lua
    LICENSE: vendor/lib_lua.LICENSE
  rev: git-hash
```


### Recursive!

If one of your targets actually has a `peru.yaml` file, you can recursively
download that target's dependencies, too!

```yaml
git module lualib_recursive:
  url: https://server.org/lualib_recursive
  recursive: true
```

If you only need a specific dependency of a dependency, you can skip `recursive`
and reference it in your own `imports` section, eg:

```yaml
imports:
  dependency.sub_dependency: ./target

... definition of dependency ...
```


### jj ZZ

Since I started learning some game dev things, I've been treating it like any
standard software project: tests, build scripts, CI, dependency management,
asset management...

It has definitely been a distraction, and I know that real game development
companies have their own tooling for stuff like this - but I'm glad I was able
to find something simple that does exactly what I need without being overly
complicated.


[1]: https://github.com/Alloyed/loverocks
[2]: https://github.com/buildinspace/peru
