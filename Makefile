#
# Copyright 2014, NICTA
#
# This software may be distributed and modified according to the terms of
# the GNU General Public License version 2. Note that NO WARRANTY is provided.
# See "LICENSE_GPLv2.txt" for details.
#
# @TAG(NICTA_GPL)
#
#
# Targets
TARGETS := elfloader.o

# Defines for Genode AM335x stand alone build as default:
STAGE_DIR=./
ARCH?=arm
PLAT?=am335x
ARMV?=armv7-a
TOOLPREFIX?=armv7a-hardfloat-linux-gnueabi-

NK_ASFLAGS += -DARMV7_A

SOURCE_DIR=./

# Source files required to build the target
CFILES   := $(patsubst $(SOURCE_DIR)/%,%,$(wildcard $(SOURCE_DIR)/src/*.c))
CFILES   += $(patsubst $(SOURCE_DIR)/%,%,$(wildcard $(SOURCE_DIR)/src/arch-$(ARCH)/*.c))
CFILES   += $(patsubst $(SOURCE_DIR)/%,%,$(wildcard $(SOURCE_DIR)/src/arch-$(ARCH)/plat-$(PLAT)/*.c))
CFILES   += $(patsubst $(SOURCE_DIR)/%,%,$(wildcard $(SOURCE_DIR)/src/arch-$(ARCH)/elf/*.c))
ASMFILES := $(patsubst $(SOURCE_DIR)/%,%,$(SOURCE_DIR)/src/arch-$(ARCH)/crt0.S)
ASMFILES += $(patsubst $(SOURCE_DIR)/%,%,$(wildcard $(SOURCE_DIR)/src/arch-$(ARCH)/plat-$(PLAT)/*.S))

NK_CFLAGS += -D_XOPEN_SOURCE=700

ifeq ($(ARMV),armv5)
ASMFILES += $(patsubst $(SOURCE_DIR)/%,%,$(SOURCE_DIR)/src/arch-$(ARCH)/mmu-v5.S)
endif
ifeq ($(ARMV),armv6)
ASMFILES += $(patsubst $(SOURCE_DIR)/%,%,$(SOURCE_DIR)/src/arch-$(ARCH)/mmu-v6.S)
endif
ifeq ($(ARMV),armv7-a)
ASMFILES += $(patsubst $(SOURCE_DIR)/%,%,$(SOURCE_DIR)/src/arch-$(ARCH)/smc.S)
ASMFILES += $(patsubst $(SOURCE_DIR)/%,%,$(SOURCE_DIR)/src/arch-$(ARCH)/mmu-v7a.S)
ASMFILES += $(patsubst $(SOURCE_DIR)/%,%,$(SOURCE_DIR)/src/arch-$(ARCH)/mmu-v7a-hyp.S)
endif

INCLUDE_DIRS += $(SOURCE_DIR)/src/arch-arm/plat-$(PLAT)/

NK_CFLAGS += -ffreestanding -Wall -Werror -W
CFLAGS += -march=armv7-a -DARMV7_A
CFLAGS += -mfloat-abi=hard
CFLAGS += -mfpu=vfpv3-d16
CFLAGS += -mtls-dialect=gnu

include common.mk

#
# We produce a partially linked object file here which, to be used, will be
# eventually relinked with the compiled kernel and user images forming
# a bootable ELF file.
#
elfloader.o: $(OBJFILES)
	@echo " Build for $(ARCH) $(PLAT) $(ARMV)"
	@echo " [LINK] $@"
	${Q}$(CC) -DARMV7_A -r $^ $(LDFLAGS) -o $@
