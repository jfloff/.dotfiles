# \\[._.]/ - Hi, I'm the OSX bot

My father is @atomantic but I was adopted by @jfloff.

I will update your OSX machine with better system defaults, preferences, software configuration and even auto-install some handy development tools and apps I find helpful.

You don't need to install or configure anything upfront! This works with a brand-new machine as well as an existing machine that you've been working with for years.

# Forget About Manual Configuration!

Don't you hate getting a new laptop or formatting yourr existing one and then spending a whole day setting up your system preferences and tools? Me too. That's why we automate; we did it once and we don't want to do have to do it again.

\\[^_^]/ - This started as Adam Eivy's OSX shell configuration dotfiles but has grown to a mutil-developer platform for machine configuration. Now @jfloff is adopting me.

\\[._.]/ - I'm so excited I just binaried in my pants!

# Watch me run!
[![asciicast](https://asciinema.org/a/cojgbj3kj4o0psbhy3kdm9mht.png)](https://asciinema.org/a/cojgbj3kj4o0psbhy3kdm9mht)

# Running

Note: I recommend forking this repo in case you don't like anything I do and want to set your own preferences (and pull request them!)
```bash
git clone --recurse-submodules https://github.com/jfloff/.dotfiles ~/.dotfiles
cd ~/.dotfiles;
./install.sh;
```

You can also fork the [original repo](https://github.com/atomantic/dotfiles) from @atomantic

> Note: running install.sh is idempotent. You can run it again and again as you add new features or software to the scripts! I'll regularly add new configurations so keep an eye on this repo as it grows and optimizes.

# ¯\\_(ツ)_/¯ Warning / Liability
> Warning:
The creator of this repo is not responsible if your machine ends up in a state you are not happy with. If you are concerned, look at all shell scripts (osx.sh, brew.sh, casks.sh, extras.sh) to review everything this script will do to your machine :)

# Restoring Dotfiles

If you have existing dotfiles for configuring git, zsh, vim, etc, these will be backed-up into ~/.dotfiles_backup and replaced with the files from this project. You can restore your original dotfiles by using `./restore.sh`

# Contributions
Contributions are always welcome in the form of pull requests with explanatory comments.

Please refer to the [Contributor Covenant](https://github.com/atomantic/dotfiles/blob/master/CODE_OF_CONDUCT.md)

# Loathing, Mehs and Praise
1. Loathing should be directed into pull requests that make it better. woot.
2. Bugs with the setup should be put as GitHub issues.
3. Mehs should be > /dev/null
4. Praise should be directed to [@antic](http://twitter.com/antic) or [@matthewmccull](http://twitter.com/matthewmccull) or [@mathiasbynens](https://github.com/mathiasbynens/dotfiles)


# Release History

### <sup>v1.1.0</sup>
 * Added dotfiles backup and restore.sh script
     * you can now restore your previous dotfiles with ./restore.sh
 * prompting the user more (e.g. `brew upgrade` is now optional)
