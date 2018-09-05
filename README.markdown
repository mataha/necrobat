# necrobat

[![Project Status: Inactive – The project has reached a stable, usable state but is no longer being actively developed; support/maintenance will be provided as time allows.](https://www.repostatus.org/badges/latest/inactive.svg)](https://www.repostatus.org/#inactive)

A really simple batch script for NecroBot. Handles updates, disconnects from
the server and sudden bot crashes.

## Installation

 1. Make sure you have the following dependencies:
    * `cmd.exe`

 2. Clone the [source](https://github.com/mataha/necrobat.git) with `git`:
    ```batchfile
    > git clone https://github.com/mataha/necrobat.git
    > cd necrobat
    ```

 3. Move the main script to your NecroBot directory:
    ```batchfile
    > move /Y "scripts\necrobat.bat" "<your NecroBot directory>"
    ```

Alternatively, you can download the source as a
[zip](https://github.com/mataha/necrobat/archive/master.zip) and install it
manually, thus avoiding using Git.

## Usage

```batchfile
necrobat
```
    
## Configuration 

If `NecroBot.exe` and `Config\` reside in the same directory as the main
script, you're fully set.

Otherwise, see the [main script](scripts/necrobat.bat) for details
on configuring.

## Development

Halted - I'm just fixing small mistakes. Feel free to fork this project.

## License

Distributed under the same terms as NecroBot itself, thus GPLv3.
See [LICENSE](LICENSE.txt) for details.
