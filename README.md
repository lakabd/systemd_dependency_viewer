# systemd dependency viewer
This is a simple tool that can help you view and mind-map the dependency tree of systemd services.
The script generates a static HTML web page based upon the svg output of `systemd-analyze plot` command.

## Demo
![alt text](https://raw.githubusercontent.com/lakabd/systemd_dependency_viewer/main/demo.gif)

dot to svg convertion is done statically using a javascript application [viz.js](https://lakabd.github.io/viz.js) (a JS compiled [graphviz(C)](https://graphviz.org/download/), using [emscripten](https://github.com/kripken/emscripten)).
