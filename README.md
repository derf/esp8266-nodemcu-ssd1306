# ESP8266 Lua/NodeMCU framebuffer + module for SSD1306 OLEDs

This repository contains a Lua module (`ssd1306.lua`), framebuffer
(`framebuffer.lua`) and fonts (`pixeloperator.lua`, `terminus16.lua`)
for using **SSD1306**-based OLEDs with ESP8266/NodeMCU firmware.

## Dependencies

ssd1306.lua and framebuffer.lua have been tested with Lua 5.1 on NodeMCU
firmware 3.0.1 (Release 202112300746, integer build). They require the
following modules.

* bit
* i2c

## Usage

Copy **framebuffer.lua**, **ssd1306.lua** and (depending on your font choice)
**pixeloperator.lua** or **terminus16.lua** to your NodeMCU board and set them
up as follows.

```lua
i2c.setup(0, sda_pin, scl_pin, i2c.SLOW)
ssd1306 = require("ssd1306")
fn = require("pixeloperator") -- or "terminus16"
fb = require("framebuffer")
collectgarbage()

ssd1306.init(128, 64) -- assuming that a 128x64 OLED is connected
ssd1306.contrast(255) -- maximum contrast
fb.init(128, 64) -- initialize framebuffer for 128x64 pixels
fb.print(fn, "Hello from NodeMCU!\nHello yes, this is Lua\n")
ssd1306.show(fb.buf)
```
