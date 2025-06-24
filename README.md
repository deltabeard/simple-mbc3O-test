# simple-mbc3O-test

A simple test ROM that exercises the MBC3O (formerly MBC30) memory bank controller. The ROM switches through all 255 available ROM banks and verifies that each of the eight RAM banks can be written and read back correctly. Progress is printed to the serial port and a success or failure message is drawn to the screen using tiles.

The code was generated with the help of AI tools. I needed a simple MBC3O test ROM to add support for MBC3O to [Peanut-GB](https://github.com/deltabeard/Peanut-GB). As such, I have released this tool under a public domain license.

## Building

Run `make` to assemble and link `main.gb` using RGBDS. The resulting ROM is titled `MBC3OTEST` and built for an MBC3 cartridge with 64KB of RAM. Use `make clean` to remove the build outputs.

## License

Copyright (c) 2025 Mahyar Koshkouei<br>
Redistribution and use in source and binary forms, with or without modification, are permitted.<br>
THIS SOFTWARE IS PROVIDED 'AS-IS', WITHOUT ANY EXPRESS OR IMPLIED WARRANTY. IN NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE USE OF THIS SOFTWARE. 
