TOPDIR := $(shell git rev-parse --show-toplevel)
include zephyr.env
export $(shell sed 's/=.*//' zephyr.env)

ZEPHYR_DIR ?= ${ZEPHYR_DIR_DEFAULT}
TOOLCHAIN_DIR ?= ${TOOLCHAIN_DIR_DEFAULT}
DL_CACHE_DIR ?= ${DL_CACHE_DIR_DEFAULT}

BOARD ?= qemu_x86
export BOARD
BOARD_DIR := $(BUILD_DIR)/${BOARD}

ARCH := $(shell uname -m)
TOOLCHAIN_NAME := zephyr-sdk-${TOOLCHAIN_VERSION}_linux-$(ARCH)

# Download paths
TOOLCHAIN_DL_PATH := $(DL_CACHE_DIR)/$(TOOLCHAIN_NAME).tar.xz
HOSTTOOLS_DL_PATH := $(DL_CACHE_DIR)/hosttools.tar.xz

PATH := $(VIRTUAL_ENV)/bin:$(HOSTTOOLS_DIR)/usr/bin:$(PATH)

.PHONY: all env build flash clean clean-system menuconfig setup

all: build

env:
	env

build: setup
	west build . --pristine

flash:
	@[ "${BOARD}" = "qemu_x86" ] && west build -t run \
	    || west flash --build-dir $(BOARD_DIR)

clean:
	@rm -rf $(BOARD_DIR)

clean-system:
	rm -rf ${BUILD_DIR}

menuconfig:
	west build -t menuconfig

setup: $(DL_CACHE_DIR) $(TOOLCHAIN_DIR_LINK) $(ZEPHYR_DIR_LINK)

$(DL_CACHE_DIR):
	mkdir -p $(@)

$(TOOLCHAIN_DL_PATH):
	curl --progress-bar -Lo \
		$(@) https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${TOOLCHAIN_VERSION}/$(TOOLCHAIN_NAME).tar.xz

$(HOSTTOOLS_DL_PATH):
	curl --progress-bar -Lo \
		$(@) https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${TOOLCHAIN_VERSION}/hosttools_linux-$(ARCH).tar.xz

$(TOOLCHAIN_DIR): $(TOOLCHAIN_DL_PATH) $(HOSTTOOLS_DL_PATH)
	mkdir -p $(@)
	tar -xf $(TOOLCHAIN_DL_PATH) -C $(@) --strip 1
	tar -xf $(HOSTTOOLS_DL_PATH) -C $(@)
	$(@)/zephyr-sdk-$(ARCH)-hosttools-standalone-0.9.sh -y -d $(@) &> /dev/null
	echo ${TOOLCHAIN_VERSION} >> $(@)/VERSION

$(TOOLCHAIN_DIR_LINK): $(TOOLCHAIN_DIR)
	@mkdir -p $(BUILD_DIR)
	@rm -f '$(@)'
	@ln -s $(shell realpath -s --relative-to $(BUILD_DIR) '$(<)') '$(@)'

$(ZEPHYR_DIR):
	mkdir -p $(@)
	python3 -m venv $(@)/.venv
	. $(@)/.venv/bin/activate \
	  && pip install west \
	  && west init --mr v${ZEPHYR_VERSION} $(@)/ \
	  && cd $(@) \
	  && west update \
	  && west zephyr-export \
	  && pip install -r zephyr/scripts/requirements.txt \
	  && west config build.dir-fmt "build/{board}"

$(ZEPHYR_DIR_LINK): $(ZEPHYR_DIR)
	@mkdir -p $(BUILD_DIR)
	@rm -f '$(@)'
	@ln -s $(shell realpath -s --relative-to $(BUILD_DIR) '$(<)') '$(@)'
