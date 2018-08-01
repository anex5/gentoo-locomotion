ifneq ($(BINDIR),)
BINDIR      := $(BINDIR)/
else
BINDIR      := $(dir $(firstword $(wildcard /usr/bin/gfxboot-compile) $(wildcard /usr/bin/mkbootmsg) $(wildcard ../../gfxboot-compile) $(wildcard ../../mkbootmsg)))
endif
ifneq ($(PRIVBINDIR),)
PRIVBINDIR  := $(PRIVBINDIR)/
else
PRIVBINDIR  := $(dir $(firstword $(wildcard /usr/share/gfxboot/bin/keymapchars) $(wildcard ../../keymapchars)))
endif

ifneq (,$(wildcard $(BINDIR)gfxboot-compile))
MKBOOTMSG    = $(BINDIR)gfxboot-compile
else
#MKBOOTMSG    = $(BINDIR)mkbootmsg
MKBOOTMSG    = $(BINDIR)gfxboot-compile
endif
KEYMAPCHARS  = $(PRIVBINDIR)keymapchars
BFLAGS       = -O -v -L ../..
INCLUDES     = $(wildcard *.inc)
# Filter out Arabic, Indic languages, and Thai, which we cannot render, and
# Dzongkha and Mongolian, which ought to be rendered vertically.
# gfxboot has no bidirectional text support yet
# (https://bugs.launchpad.net/ubuntu/+source/gfxboot/+bug/212491) so
# right-to-left languages (Arabic) won't work. This can be worked-around
# by displaying RTL text in visual format (which works well for Hebrew and should
# be considered for use in other languages where applicable)
TRANSLATIONS = $(addsuffix .tr,en $(filter-out ar bn bo dz gu hi km ml mn my ne pa ta th ug, $(notdir $(basename $(wildcard po/*.po)))))

DEFAULT_LANG =

PIC_COMMON   = back.jpg

FILES_CORE   = init

INST_EXT     = langlist $(TRANSLATIONS) 16x16.fnt $(PIC_COMMON)

FILES_INST   = $(FILES_CORE) $(INST_EXT)

FILES_BOOT   = $(FILES_CORE) langlist $(TRANSLATIONS) 16x16.fnt \
	       $(PIC_COMMON)

FILES_BOOT_EN = $(FILES_CORE) en.tr 16x16.fnt $(PIC_COMMON)

ifdef DEFAULT_LANG
FILES_INST += lang
FILES_BOOT += lang
FILES_BOOT_EN += lang $(patsubst boot/%,%,$(wildcard boot/$(DEFAULT_LANG).tr))
endif

.PHONY: all themes font clean po

all: themes

boot install: po
	mkdir -p $@

po:
	make -C po

themes: bootdir installdir

bootdir: boot.config boot $(INCLUDES)
	@cp -a po/*.tr boot
	@for i in $(FILES_BOOT) ; do [ -f $$i ] && cp $$i boot ; done ; true
	@echo en >boot/langlist
	$(MKBOOTMSG) $(BFLAGS) -l boot/log -c $< boot/init
ifdef DEFAULT_LANG
	@echo $(DEFAULT_LANG) >boot/lang
	@echo $(DEFAULT_LANG) >>boot/langlist
endif
	@cd boot && echo $(FILES_BOOT_EN) | sed -e "s/ /\n/g" | cpio --quiet -o >message

installdir: install.config install $(INCLUDES)
	@cp -a po/*.tr install
	@for i in $(FILES_INST) ; do [ -f $$i ] && cp $$i install ; done ; true
	$(MKBOOTMSG) $(BFLAGS) -l install/log -c $< install/init
ifdef DEFAULT_LANG
	@echo $(DEFAULT_LANG) >install/lang
endif
	@cd install && find | sed -e "s/ /\n/g" | grep -v bootlogo | cpio --quiet -o >bootlogo
	@tar -C install -czf install/bootlogo.tar.gz bootlogo $(INST_EXT)

font:
	cat po/*.po >tmp.txt
	gfxboot-font -v -l 16 \
	-p /usr/share/fonts/droid:/usr/share/fonts/unifont \
	-a 0x2022-0x2023 \
	-c ISO-8859-15 -c ISO-8859-2 -c koi8-r \
	`$(KEYMAPCHARS) keytables.inc` \
	-t tmp.txt \
	-t install/log -t boot/log \
	-t langlist -t langnames.inc \
	-f "DroidSans":size=13 \
	-f unifont:prop=2:space_width=4:size=16 \
	16x16.fnt >16x16.fnt.log
	rm -f tmp.txt

clean:
	make -C po clean
	rm -f bootdir installdir *~ *.log
	rm -rf boot install

