DIRS = \
	appimgui \
	dcimgui \
	fonticon \
	glfw \
	imfileopendialog \
	imknobs\
	impl_glfw \
	impl_opengl3 \
	imspinner \
	imtoggle \
	loadicon \
	loadimage \
	saveimage \
	setupfont \
	utils \
	zoomglass

all:
	clear
	$(foreach exdir,$(DIRS), $(call def_make,$(exdir),$@))

clean:
	$(foreach exdir,$(DIRS), $(call def_make,$(exdir),$@))

fmt:
	$(foreach exdir,$(DIRS), $(call def_make,$(exdir),$@))

#
define def_make
	@echo ==== Enter: $(1) ====
	@-$(MAKE) -C  $(1) $(2)

endef

MAKEFLAGS += --no-print-directory
