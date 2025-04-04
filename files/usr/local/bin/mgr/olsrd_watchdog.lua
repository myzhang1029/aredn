
--[[

    Part of AREDN® -- Used for creating Amateur Radio Emergency Data Networks
    Copyright (C) 2021 Tim Wilkinson
    Original Shell Copyright (C) 2019 Joe Ayers AE6XE
    See Contributors file for additional contributors

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Additional Terms:

    Additional use restrictions exist on the AREDN® trademark and logo.
        See AREDNLicense.txt for more info.

    Attributions to the AREDN® Project must be retained in the source code.
    If importing this code into a new or existing project attribution
    to the AREDN® project must be added to the source code.

    You must not misrepresent the origin of the material contained within.

    Modified versions must be modified to attribute to the original source
    and be marked in reasonable ways as differentiate it from the original
    version

--]]

local watchdogfile = "/tmp/olsrd.watchdog"
local sleeptime = 1 * 60 -- 1 minute
local timeout = 10 * 60 -- 10 minutes

function olsrd_watchdog()
    while true
    do
        wait_for_ticks(sleeptime)
        if nixio.fs.stat(watchdogfile) then
            local watchtime = tonumber(read_all(watchdogfile))
            -- If watchtime hasn't update recently or we cannot talk to it, then we restart OLSRD
            local sigsock = nixio.socket("inet", "stream")
            local connection = sigsock:connect("127.0.0.1", 2006)
            sigsock:close()
            if watchtime + timeout < os.time() or connection ~= true then
                nixio.syslog("err", "olsrd watchdog timeout - restarting")
                os.remove(watchdogfile)
                os.execute("/etc/init.d/olsrd restart")
            end
        end
    end
end

return olsrd_watchdog
