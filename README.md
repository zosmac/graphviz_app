# graphviz_app
macOS App project for *[Graphviz](<https://graphviz.org>)*

This project originates from the contents of the `macosx` folder of the *[Graphviz project](<https://gitlab.com/graphviz/graphviz>)* repository.

To build this project, first install *Graphviz* on your Mac, which this project assumes is configured specifying `--with-quartz --prefix=/usr/local/graphviz`.

Then run `make` to install this app into `/Applications/Graphviz.app`.
```sh
make PREFIX=/usr/local/graphviz
```
