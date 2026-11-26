# dotfiles

An installer and shared configuration that give every Linux machine and Dev container the same shell and development setup.

## Language

### Installing

**Installer**:
The single entry point that sets up every Tool included in the chosen Install mode.
_Avoid_: setup script, bootstrap

**Install mode**:
How much the Installer sets up: Minimal mode or Full mode. It is chosen per machine, not inferred from where the Installer runs.
_Avoid_: profile, environment, target

**Minimal mode**:
The default Install mode, which sets up the core set of Tools.
_Avoid_: standard, default install, dev container mode

**Full mode**:
The Install mode that sets up every Tool, including those Minimal mode leaves out or leaves unconfigured.
_Avoid_: workstation mode, full install

**Tool**:
One program or configuration set that the Installer sets up as a unit, such as git, omz or neovim.
_Avoid_: package, module, component

**Install step**:
Putting a Tool's program on the machine.
_Avoid_: setup

**Configure step**:
Applying this repo's settings and plugins to a Tool.
_Avoid_: setup, linking

### Environments

**Dev container**:
A development container that the VS Code Dev Containers extension builds and then runs the Installer in.
_Avoid_: devcontainer, container

**Host**:
The machine a Dev container runs on, whose Git identity is copied into the container.
_Avoid_: parent, local machine

**Workstation**:
A machine chosen to run Full mode, such as a laptop, a desktop or a jump server.
_Avoid_: machine, fleet

**Lab server**:
A lab machine, physical or virtual, that runs Minimal mode, such as a hypervisor or one of the virtual machines it runs.
_Avoid_: lab VM, fleet

### Git

**Shared Git config**:
The Git settings this repo tracks and applies the same way on every machine.
_Avoid_: global config, gitconfig

**Git identity**:
A machine's own Git user name, email and signing key, kept outside this repo.
_Avoid_: user config, personal config
