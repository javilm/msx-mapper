echo "* Assembling MAPPER.ASM *
as mapper.asm
echo "* Assembling BIN2STR.ASM *
as bin2str.asm
echo "* Linking *"
ld mapper=mapper,bin2str
echo "* Cleaning up *"
del mapper.rel
del bin2str.rel
del *.sym

