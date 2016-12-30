# todo.txt-mit

This is a reimplementation of the [MIT add-on](https://github.com/codybuell/mit) for [`todo.txt-cli`](https://github.com/ginatrapani/todo.txt-cli/) in Ruby.

The main reason for this reimplementation's existence is that I agree with the original author that [it would be nice if the add-on was faster](https://github.com/codybuell/mit/blob/d4fbdd203f04098ff8cfcd39a6fa8bb3226b6b03/mit#L49).

## Installation

Start by cloning this repo.
As with all other add-ons, you'll need to place an executable in your `~/.todo.actions.d` folder (see [Installing Addons](https://github.com/ginatrapani/todo.txt-cli/wiki/Creating-and-Installing-Add-ons) for more information).

For this add-on, you can either create a symlink in the `~/.todo.actions.d` folder pointing to the executable ([`bin/mit`](bin/mit)), or generate a single file script that you can place in said folder.

#### Symlink

```plain
ln -s ~/.todo.actions.d/mit /foo/bar/todo.txt-mit/bin/mit
```

#### Generated script

```plain
/foo/bar/todo.txt-mit/generate_script > ~/.todo.actions.d/mit
chmod +x ~/.todo.actions.d/mit
```

## Running the tests

You'll need the [`rspec`](https://github.com/rspec/rspec) gem installed to be able to run the tests:

```
gem install rspec
```

Running the tests is done by invoking `rspec`:

```
rspec spec
```
