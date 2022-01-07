echo "* Assembling MAPPER.AS *
as mapper.as
echo "* Assembling BIN2STR.AS *
as bin2str.as
echo "* Linking *"
ld mapper=mapper,bin2str
echo "* Cleaning up *"
del mapper.rel
del bin2str.rel
del *.sym

