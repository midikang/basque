TITLE=basque

# \
!ifndef 0 # \
# nmake: \
CP=copy # \
MV=move # \
RM=del # \
CC=clang # \
SOURCE=source\$(TITLE).c # \
LIBS=-I C:\INCLUDE\ -L C:\INCLUDE\SDL2\ -Xlinker windows\$(TITLE).res -l Shell32 -l C:\INCLUDE\SDL2\SDL2.lib -l C:\INCLUDE\SDL2\SDL2main.lib -l C:\INCLUDE\SDL2\SDL2_image.lib -l C:\INCLUDE\SDL2\SDL2_mixer.lib -l C:\INCLUDE\SDL2\SDL2_ttf.lib -Xlinker /SUBSYSTEM:WINDOWS # \
TARGET=-o $(TITLE).exe && mt.exe -nologo -manifest windows\$(TITLE).manifest -outputresource:$(TITLE).exe # \
COMPILE=rc.exe /nologo windows\$(TITLE).rc && $(CC) $(FLAGS) $(SOURCE) $(LIBS) # \
!else
# make:
CP=cp -f
MV=mv -f
RM=rm -f
# If this fancy syntax doesn't work with your version of `make`,
# just the conditional wrapper (ifeq and endif).
ifeq ($(origin CC), default)
CC=clang
endif
SDL2_FLAGS=`$$(which sdl2-config) --cflags --libs`
SOURCE=source/$(TITLE).c
LIBS='-Wl,-rpath,$$ORIGIN' $(SDL2_FLAGS) -l SDL2_image -l SDL2_mixer -l SDL2_ttf
TARGET=-o $(TITLE)
COMPILE=$(CC) $(FLAGS) $(SOURCE) $(LIBS)
# \
!endif

FLAGS=-Wall -Wextra -std=c99
RELEASE=$(COMPILE) $(TARGET)
DEBUG=$(COMPILE) -g $(TARGET)
MEMDEBUG=$(COMPILE) -g -fsanitize=address $(TARGET)

$(TITLE): source/*.c source/*.h
	$(RELEASE)
# Windows will automatically overwrite
# the binary when using `nmake`, but
# we add the clean command for
# people who like that kind
# of thing.
clean:
	$(RM) $(TITLE)
	$(RM) $(TITLE).exe
force:
	$(RELEASE)

debug: source/*.c source/*.h
	$(DEBUG)
memdebug: source/*.c source/*.h
	$(MEMDEBUG)

linux:
	cp $(TITLE) linux/
	cp -r assets linux/
	find /usr/lib -type f -iname "*sdl2*.so.*" -exec cp {} linux/ \;
	# for FILE in $$(ldd $(TITLE) | awk '{print $$3}'); do cp $$(readlink -e $$FILE) linux/; done
	for FILE in $$(find linux/ -type f -iname "*.so.0.*"); do ln -sfv $$(basename $${FILE}) $$(echo $${FILE} | sed 's/.so.0.*/.so.0/'); done
	zip -r $(TITLE).linux.zip linux/*
mac:
	mkdir -p mac/$(TITLE).app/Contents/Resources/
	cp $(TITLE) mac/$(TITLE).app/Contents/Resources/
	cp -r assets mac/$(TITLE).app/Contents/Resources/
	find /usr/local/Cellar -type f -iname "*sdl2*.dylib" -exec cp {} mac/$(TITLE).app/Contents/Resources/ \;
	zip -r $(TITLE).mac.zip mac/$(TITLE).app
windows:
	copy $(TITLE).exe windows\ &
	robocopy assets\ windows\assets\ /e &
	robocopy C:\INCLUDE\SDL2\ windows\ *.dll &
	powershell Compress-Archive -Force windows\* $(TITLE).windows.zip
