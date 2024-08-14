# Zephyr template

An out-of-tree [Zephyr](https://www.zephyrproject.org/) template.

## Getting started

The following prerequisites are needed to configure, build and flash the
project onto a supported board.

### Prerequisites

- Install [cmake](https://cmake.org/)
- Install [ninja-build](https://ninja-build.org/)
- Install [python3-venv](https://docs.python.org/3/library/venv.html)
- Install [direnv](https://direnv.net/)
- Install [asdf](https://asdf-vm.com/guide/getting-started.html)
- Setup `.envrc`. See `.envrc.example` for more details.

### Setting up the Zephyr Kernel and Toolchian

```shell
make setup
```

### Building the firmware

```shell
make build
```

### Flashing the firmware

```shell
make flash
```
