---
layout:        post
title:         "npm install without sudo"
date:          2017-04-26
category:      JavaScript
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      false
published:     true
---

# Install npm packages globally without sudo on macOS and Linux

`npm` installs packages locally within your projects by default. You can also install packages globally (e.g. `npm install -g <package>`) (useful for command-line apps). However the downside of this is that you need to be root (or use `sudo`) to be able to install globally.

Here is a way to install packages globally for a given user.

###### 1. Create a directory for global packages

```sh
mkdir "$HOME/.npm-packages"
```

###### 2. Indicate to `npm` where to store globally installed packages. In your `~/.npmrc` file add:

```sh
prefix=$HOME/.npm-packages
```

###### 3. Ensure `npm` will find installed binaries and man pages. Add the following to your `.bashrc`/`.zshrc`:

```sh
PATH="$PATH:$HOME/.npm-packages/bin"
```

---

See also: `npm`'s documentation on
["Fixing `npm` permissions"](https://docs.npmjs.com/getting-started/fixing-npm-permissions).
