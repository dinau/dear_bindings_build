# All example are built at a time.
EXAMPLE_DIRS :=	examples/glfw_opengl3 \
	              examples/glfw_opengl3_image_load \
	              examples/glfw_opengl3_image_save \
	              examples/glfw_opengl3_jp \
	              examples/sdl2_opengl3 \
	              examples/sdl3_opengl3

all:
	$(foreach exdir,$(EXAMPLE_DIRS), $(call def_make,$(exdir),$@ ))

.PHONY: test clean gen
test:
	@echo $(notdir $(EXAMPLE_DIRS))

clean:
	$(foreach exdir,$(EXAMPLE_DIRS), $(call def_make,$(exdir),cleanall ))

gen:
	$(foreach exdir,$(EXAMPLE_DIRS), $(call def_make,$(exdir),$@ ))


#
define def_make
	@$(MAKE) -C  $(1) $(2)

endef

#MAKEFLAGS += --no-print-directory
