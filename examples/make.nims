import std/[os,strutils]

var projDirs = @[
"glfw_opengl3",
"glfw_opengl3_jp",
"sdl2_opengl3",
"sdl3_opengl3"
]

#-------------
# compileProj
#-------------
proc compileProj(cmd:string) =
  var options = ""
  #options =  join([options,"--no-print-directory"]," ")

  for dir in projDirs:
    if dir.dirExists:
      withDir(dir):
        exec("make $# $#" % [options,cmd])

#------
# main
#------
var cmd:string
if commandLineParams().len >= 2:
  cmd = commandLineParams()[1]
compileProj(cmd)
