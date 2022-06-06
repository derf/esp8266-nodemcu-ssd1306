local fb = {}

fb.w = 0
fb.h = 0
fb.x = 0
fb.y = 0
fb.buf = nil

function fb.init(w, h)
	fb.w = w
	fb.h = h
	fb.x = 0
	fb.y = 0
	fb.buf = {}
end

function fb.scroll()
	for x = 0, fb.w-1 do
		for y = 1, fb.h/32 do
			fb.buf[x*(fb.h/32) + y-1 + 1] = bit.rshift(fb.buf[x*(fb.h/32) + y-1 + 1] or 0, 8) or nil
			if y ~= fb.h/32 then
				fb.buf[x*(fb.h/32) + y-1 + 1] = bit.bor(fb.buf[x*(fb.h/32) + y-1 + 1] or 0, bit.lshift(fb.buf[x*(fb.h/32) + y + 1] or 0, 24)) or nil
			end
		end
	end
	fb.y = fb.y - 8
end

function fb.put(font, c)
	if c == 10 then
		fb.x = 0
		fb.y = fb.y + font.height
		return
	end
	if c < 32 or c > 126 then
		c = 0x3f
	end
	if fb.y >= fb.h then
		fb.scroll()
	end
	local glyph = font.glyphs[c - 31]
	local fh = font.height/8
	for i = 1, string.len(glyph) do
		local x1 = (i-1) / fh
		local y8 = (i-1) % fh
		local fb8_o = fb.y/8+y8 + (fb.x+x1) * (fb.h/8)
		local fb32_o = fb8_o / 4 + 1
		local fb32_s = (fb8_o % 4) * 8
		fb.buf[fb32_o] = bit.bor(fb.buf[fb32_o] or 0, bit.lshift(string.byte(glyph, i), fb32_s))
	end
	fb.x = fb.x + string.len(glyph) / fh + 2
	if fb.x > fb.w then
		fb.put(font, 10)
	end
end

function fb.print(font, str)
	for i = 1, string.len(str) do
		fb.put(font, string.byte(str, i))
	end
end

function fb.draw_battery_8(x, y, p)
	fb.buf[y/32 + x*fb.h/32 + 1] = 0xff
	for i = 1, 10 do
		if p*2 >= i*15 then
			fb.buf[y/32 + (x+i)*fb.h/32 + 1] = 0xff
		else
			fb.buf[y/32 + (x+i)*fb.h/32 + 1] = 0x81
		end
	end
	if p*2 >= 11*15 then
		fb.buf[y/32 + (x+11)*fb.h/32 + 1] = 0xff
	else
		fb.buf[y/32 + (x+11)*fb.h/32 + 1] = 0xe7
	end
	if p*2 >= 12*15 then
		fb.buf[y/32 + (x+12)*fb.h/32 + 1] = 0x3c
	else
		fb.buf[y/32 + (x+12)*fb.h/32 + 1] = 0x24
	end
	fb.buf[y/32 + (x+13)*fb.h/32 + 1] = 0x3c
end

return fb
