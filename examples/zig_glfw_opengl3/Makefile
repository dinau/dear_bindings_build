# Use zig-0.12.0
# by dinau (2024/06)
#
OPT += --release=fast
#OPT += --release=small
# Fail compilation
#OPT += --release=safe

all:
	zig build $(OPT)

run: all
	./zig-out/bin/glfw_opengl3.exe

cleanall:
	rm -fr zig-out
	rm -fr zig-cache
