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
		for y = 1, fb.h/8-1 do
			fb.buf[x*(fb.h/8) + y-1 + 1] = fb.buf[x*(fb.h/8) + y + 1] or nil
		end
		fb.buf[x*(fb.h/8) + fb.h/8] = nil
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
		fb.buf[fb.y/8+y8 + (fb.x+x1) * (fb.h/8) + 1] = string.byte(glyph, i)
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
	fb.buf[y/8 + x*fb.h/8 + 1] = 0xff
	for i = 1, 10 do
		if p*2 >= i*15 then
			fb.buf[y/8 + (x+i)*fb.h/8 + 1] = 0xff
		else
			fb.buf[y/8 + (x+i)*fb.h/8 + 1] = 0x81
		end
	end
	if p*2 >= 11*15 then
		fb.buf[y/8 + (x+11)*fb.h/8 + 1] = 0xff
	else
		fb.buf[y/8 + (x+11)*fb.h/8 + 1] = 0xe7
	end
	if p*2 >= 12*15 then
		fb.buf[y/8 + (x+12)*fb.h/8 + 1] = 0x3c
	else
		fb.buf[y/8 + (x+12)*fb.h/8 + 1] = 0x24
	end
	fb.buf[y/8 + (x+13)*fb.h/8 + 1] = 0x3c
end

return fb
