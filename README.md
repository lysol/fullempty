# fullempty.sh

This is a static site generator for my personal (browser) homepage.
It's not fully genericized but can be simply modified to suit anyone else's similar
needs. The only prerequisite for this system is bash 4.

## Quickstart

See `content/index.post.sh` and `content/index.html` for a simple example. There are no
automatic loops or anything like that. Simply fill out the `content` property to provide
a reference to the html file with the contents to be included in the template, `filename`
for the output path. Additionally, default properties are included in `content/default.sh`,
including the default template `template.html`.

Once your files are in place, you can run `make build` to build the html files, `make sync`
to rsync the files to the location specified in the makefile in the `SYNC_TARGET` variable,
and `make clean` to delete everything in the build dir `build`.

Or, simply run `make` to all those steps in order.

## template tag types

* `<% key %>` includes the specified key in `$docvars` in the document.
* `<$ echo some bash $>` is `eval`'d in the same loop, in the scope of the main bash script.
