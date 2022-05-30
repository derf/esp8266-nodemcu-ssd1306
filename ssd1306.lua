local ssd1306 = {}

local s_CONTRAST = 0x81
local s_ENTIRE_ON = 0xa4
local s_NORM_INV = 0xa6
local s_DISP = 0xae
local s_MEM_ADDR = 0x20
local s_COL_ADDR = 0x21
local s_PAGE_ADDR = 0x22
local s_DISP_START_LINE = 0x40
local s_SEG_REMAP = 0xa0
local s_MUX_RATIO = 0xa8
local s_COM_OUT_DIR = 0xc0
local s_DISP_OFFSET = 0xd3
local s_COM_PIN_CFG = 0xda
local s_DISP_CLK_DIV = 0xd5
local s_PRECHARGE = 0xd9
local s_VCOM_DESEL = 0xdb
local s_CHARGE_PUMP = 0x8d

function ssd1306.wc(byte)
	return ssd1306.wd({0x80, byte})
end

function ssd1306.wd(data)
	i2c.start(0)
	if not i2c.address(0, 0x3c, i2c.TRANSMITTER) then
		return false
	end
	i2c.write(0, data)
	i2c.stop(0)
	return true
end

function ssd1306.init(width, height)
	ssd1306.w = width
	ssd1306.h = height
	local tab = {s_DISP, s_MEM_ADDR, 0x01, s_DISP_START_LINE, s_SEG_REMAP + 0x01,
		s_MUX_RATIO, height - 1, s_COM_OUT_DIR + 0x08, s_DISP_OFFSET, 0x00,
		s_COM_PIN_CFG, height == 32 and 0x02 or 0x12, s_DISP_CLK_DIV, 0x80,
		s_PRECHARGE, 0x88, s_VCOM_DESEL, 0x30, s_CONTRAST, 0x80, s_ENTIRE_ON,
		s_NORM_INV, s_CHARGE_PUMP, 0x14, s_DISP + 0x01, s_COL_ADDR, 0, 127,
		s_PAGE_ADDR, 0, 7}
	for i, v in ipairs(tab) do
		ssd1306.wc(v)
	end

	ssd1306.fb = string.rep("0", width * height / 8)
end

function ssd1306.show()
	local txbuf = {0x40}
	for i = 1, ssd1306.w * ssd1306.h / 8, 128 do
		for j = 0, 127 do
			txbuf[j+2] = string.byte(ssd1306.fb, i + j)
		end
		ssd1306.wd(txbuf)
	end
end

return ssd1306
