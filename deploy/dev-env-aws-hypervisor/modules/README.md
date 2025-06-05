## Modules
Modules are extensions to the developer environment setup that collect related configuration or functionality into logical packages. There are two kinds of modules to consider.

#### Config
Config modules are directories under `modules/config` that contain a `setup.sh` file that will be run on your developer environment during the `configure.sh` step that initializes the environment. This are intended to modify the system in ways such as cloning repos, installing RPMs, and more.

#### Script
Script modules are directories under `modules/script` that contain a collection of executable files that will be copied to the root directory of your developer environment during the `configure.sh` step that initializes the environment. These are intended to give you handy tools to interact with the environment and perform tasks once it's fully set up.
