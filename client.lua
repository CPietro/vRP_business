vRPbu = {}
Tunnel.bindInterface("vRP_business",vRPbu)
vRPserver = Tunnel.getInterface("vRP","vRP_business")
BUserver = Tunnel.getInterface("vRP_business","vRP_business")
vRP = Proxy.getInterface("vRP")

local blips = {
	["bank"] = {title="Pacific Standard", prezzo= 2000000, gruppo="Bank Director", x=263.72836303711,y=223.23931884766,z=101.68327331543},
}

function vRPbu.AggBlip(x,y,z,id,colour,title)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, id)
	SetBlipScale(blip, 0.9)
	SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(title)
    EndTextCommandSetBlipName(blip)
end


Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)
		for nome, data in pairs(blips) do
			if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), data.x,data.y,data.z, true ) < 1 then
				DrawSpecialText("Press [~g~E~s~] to buy the "..data.title.." for ~r~"..data.prezzo.."$")
				if(IsControlJustPressed(1, 38)) then
					BUserver.ControlloMoney({nome})
				end
			end
		end
	end
end)

function DrawSpecialText(m_text, showtime)
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(showtime, 1)
end