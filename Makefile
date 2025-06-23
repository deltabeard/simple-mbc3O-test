GBNAME = main

all: $(GBNAME).gb

$(GBNAME).gb: $(GBNAME).o
	rgblink -o $@ $<
	rgbfix -v -p 0 -t "MBC3OTEST" -l 0x33 -m MBC3+RAM -c $@

$(GBNAME).o: $(GBNAME).asm
	rgbasm -o $@ $<

clean:
	rm -f $(GBNAME).o $(GBNAME).gb
