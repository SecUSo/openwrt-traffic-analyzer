#!/usr/bin/lua

require("luci.sgi.uhttpd")
require("luci.sys")
require("luci.http")

function write_to_log()
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	local referer = luci.sys.getenv("HTTP_REFERER")
	file = io.open("/var/log/trafficanalyzer", "a")
	if (referer ~= nil) and (timestamp ~= nil) then
		file:write(timestamp .. ";" .. referer .. "\r\n")
	end
	file:flush()
	file:close()
end

package.path = package.path .. ";/www/cgi-bin/warningpage_content.lua"
local warningpage_content = require("warningpage_content")
--Show HTML for the frontend version of the warning page: backend = false
warningpage_content.html(false)
write_to_log()
