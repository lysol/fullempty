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

## Post List

Items in `content` with the `type` value in their array set to `post` will be compiled in
`posts.csv`, and a list of `<li>` elements with dates and links to those posts will be
placed in `templatevars[postlist]`, for easy inclusion in a list element in any document.
