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
	for i = 1, table.getn(glyph) do
		local x1 = (i-1) / fh
		local y8 = (i-1) % fh
		fb.buf[fb.y/8+y8 + (fb.x+x1) * (fb.h/8) + 1] = glyph[i]
	end
	fb.x = fb.x + table.getn(glyph) / fh + 2
	if fb.x > fb.w then
		fb.put(font, 10)
	end
end

function fb.print(font, str)
	for i = 1, string.len(str) do
		fb.put(font, string.byte(str, i))
	end
end

return fb
