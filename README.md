# GUI-o-Mac-tic!

This is a tool for creating minimal graphical user interfaces; usually
just a splash screen and an indicator icon with a drop-down menu.

This tool is a native Mac port of [GUI-o-Matic!](https://github.com/mailpile/gui-o-matic). GUI-o-Matic was
initially written as part of [Mailpile](https://www.mailpile.is), but was then
[released seperately](https://github.com/mailpile/gui-o-matic) for other projects to make use of it.

The tool is inspired by `dialog` and other similar command-line
utilities which provide drop-in user interfaces for shell scripts.
It also a drop-in UI, but it differs from these tools in that it is
meant to be used as long-running process, either
communicating with a background process (a worker) or providing access
to URLs or shell commands.

Background worker processes can mutate GUI-o-Mac-tic's state using a
JSON-based protocol, and the GUI can communicate back or perform
actions based on user input in numerous ways. Background workers that
need richer user interfaces, than are provided by GUI-o-Mac-tic, are
expected to expose web- or terminal interfaces which GUI-o-Mac-tic can
launch as necessary.

When used without a worker, GUI-o-Mac-tic can provide point-and-click
access to shell commands or URLs (see [examples][./scripts/]).

## Project Status and License

This project is **a work in progress**. Please feel free to help out!

## Supported Platforms

GUI-o-Mac-tic is written for macOS.

Other platforms are supported by [GUI-o-Matic](https://github.com/mailpile/gui-o-matic)

If you have experience developing user interface code, please consider helping out!


## User Interface

GUI-o-Mac-tic currently allows creation of the following UI elements and
behaviours:

* A splash screen with a progress bar,
* a main window with buttons and graphics,
* a taskbar with a mutable icon and a drop-down men,
* to open URLs in browser,
* to load URLs in backgroun,
* to launch apps in terminal windows,
* to run shell commands in the background,
* to display notifications.

The UI feature-set is deliberately meant to stay small. This is to increase the
odds that the full functionality can be made available on all platforms as
this project shall conform with GUI-o-Mac-tic's [behavioural specification](https://github.com/mailpile/gui-o-matic/blob/master/PROTOCOL.md).

## Configuration and Communication

When used as a command-line tool, the `GUI-o-Mac-tic` tool will read a
JSON formatted configuration from standard-input, until it encounters
the words `OK GO` or `OK LISTEN` on a line by themselves.

In GO mode, the app will continue running until killed.

In LISTEN mode, the app will then continue reading standard input,
expecting one command per line. On EOF the app will terminate. The
command format is very simple; a command-name followed by a space and a
single JSON structure for arguments. Examples:

update_splash_screen {"progress": 0.2, "message": "Yaaay"}

set_item_label {"item": "frobnicator", "label": "FROB IT"}

notify_user {"message": "Hello World!"}

Consult the file [PROTOCOL.md](PROTOCOL.md) for a full specification
of the program and a full list of available commands. The
[scripts](./scripts/) folder contains working examples illustrating
these concepts.


## Credits and license

This is a tool for creating minimal graphical user interfaces.
Copyright 2018, Pétur Ingi Egilsson.

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
