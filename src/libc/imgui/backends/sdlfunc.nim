import pegs
for line in lines("imgui_impl_sdl2.cpp"):
  if line =~ peg" @  {'SDL_'@'('@$}":
    echo matches[0]
    #if line =~ peg"@'('@$":
      #echo matches[0]
      #echo line
