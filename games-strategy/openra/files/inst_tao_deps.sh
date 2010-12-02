#!/bin/sh

#Install the Tao dependencies (.dll and .config) from the
#thirdparty/Tao directory permanently into
#your GAC with the following script

gacutil -i thirdparty/Tao/Tao.Cg.dll
gacutil -i thirdparty/Tao/Tao.OpenGl.dll
gacutil -i thirdparty/Tao/Tao.OpenAl.dll
gacutil -i thirdparty/Tao/Tao.Sdl.dll
gacutil -i thirdparty/Tao/Tao.FreeType.dll
