MySQL = module("vrp_mysql", "MySQL")
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local htmlEntities = module("vrp", "lib/htmlEntities")
local Lang = module("vrp", "lib/Lang")

vRPbu = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_business")
BUclient = Tunnel.getInterface("vRP_business","vRP_business")
Tunnel.bindInterface("vRP_business",vRPbu)
vRPcc = Proxy.getInterface("vRP_companyaccs")
cfg = module("vrp_business", "cfg/config")
lang = Lang.new(module("vrp_business", "cfg/lang"))

MySQL.createCommand("vRP/busi_tables",[[
CREATE TABLE IF NOT EXISTS vrp_business(
    business VARCHAR(255),
	user_id INT(11) NULL DEFAULT NULL,
	bank INT(12) NOT NULL DEFAULT '0',
	pin INT(5) NOT NULL DEFAULT '0',
	CONSTRAINT pk_business PRIMARY KEY(business)
);
]])
MySQL.createCommand("vRP/get_new_business","SELECT user_id FROM vrp_business WHERE business = @business")
MySQL.createCommand("vRP/set_new_business","UPDATE vrp_business SET user_id = @user_id WHERE business = @business")
MySQL.createCommand("vRP/insert_user_business","INSERT IGNORE INTO vrp_business(business,user_id) VALUES(@business,@user_id)")

MySQL.execute("vRP/busi_tables")

local blips = cfg.blips

for nome,_ in pairs(blips) do
	local user_id = 0
	MySQL.execute("vRP/insert_user_business", {business = nome, user_id = json.encode(user_id)})
end

function vRPbu.ControlloMoney(name,titolo,gruppo,prezzo)
	local user_id = vRP.getUserId({source})
	local player = vRP.getUserSource({user_id})
	local gruppov = vRP.getUserGroupByType({user_id,"business"})
	if gruppov == "" then 
		GetStato(name, function(p_id)
			if p_id ~= user_id then
				if p_id == 0 then
					local titolo = blips[name].title
					local gruppo = blips[name].gruppo
					local prezzo = blips[name].prezzo
					if vRP.tryBankMoney({user_id,prezzo}) then
						vRP.addUserGroup({user_id,gruppo})
						TriggerClientEvent('chatMessage', -1, 'BUSINESS', { 30, 70, 255 },lang.buy.confirmation_message({GetPlayerName(player), gruppo, prezzo}))
						SetStato(name,user_id)
						vRPclient.notify(player,{lang.buy.congratulation({titolo})})
					else
						vRPclient.notify(player,{lang.buy.not_enough_money()})
					end
				else
					vRPclient.notify(player,{lang.buy.already_bought()})
				end
			else
				vRPclient.notify(player,{lang.buy.already_owned()})
			end
		end)
	else
		vRPclient.notify(player,{lang.buy.already_owned_by_you({gruppov})})
	end
end

function GetStato(business, cbr)
	local task = Task(cbr, {false})  
	MySQL.query("vRP/get_new_business", {business = business}, function(rows, affected)
		if #rows > 0 then
			task({rows[1].user_id})
		else
			task()
		end
	end)
end
  
function SetStato(business,user_id)
	MySQL.execute("vRP/set_new_business", {business = business, user_id = json.encode(user_id)})
end

local choice_vendibusiness = {function(player,choice) 
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		local gruppo = vRP.getUserGroupByType({user_id,"business"})
		vRPclient.getNearestPlayers(player,{15},function(nplayers) 
			local user_list = ""
			for k,v in pairs(nplayers) do
				user_list = user_list .. "[" .. vRP.getUserId({k}) .. "]" .. GetPlayerName(k) .. " | "
			end 
			if user_list ~= "" then
				vRP.prompt({player,lang.common.near_players({user_list}),"",function(player,target_id) 
					if target_id ~= nil and target_id ~= "" then 
						local target = vRP.getUserSource({tonumber(target_id)})
						if target ~= nil then
							vRP.prompt({player,lang.sell.offered_price(),"",function(player,costo2) 
								local costo = tonumber(costo2)
								vRP.request({target, lang.sell.ask_sale({GetPlayerName(player), gruppo, costo}), 60, function(nplayer,ok)
									if ok then 
										if vRP.tryBankMoney({target_id,costo}) then
											vRP.removeUserGroup({user_id,gruppo})
											vRP.addUserGroup({tonumber(target_id),gruppo})
											vRPclient.notify(player,{lang.common.agreed()})
											vRPclient.notify(target,{lang.sell.congratulation()})
										else
											vRPclient.notify(target,{lang.buy.not_enough_money()})
											vRPclient.notify(player,{lang.common.player_not_enough_money()})
										end
									else
										vRPclient.notify(player,{lang.common.refused()})
									end
								end})
							end})
						end
					end
				end})
			else
				vRPclient.notify(player,{lang.common.no_players_near()})
			end
		end)
	end
end}

local choice_assumi = {function(player,choice) 
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		local gruppo = vRP.getUserGroupByType({user_id,"business"})
		vRPclient.getNearestPlayers(player,{15},function(nplayers) 
			local user_list = ""
			for k,v in pairs(nplayers) do
				user_list = user_list .. "[" .. vRP.getUserId({k}) .. "]" .. GetPlayerName(k) .. " | "
			end 
			if user_list ~= "" then
				vRP.prompt({player, lang.common.near_players({user_list}),"",function(player,target_id) 
					if target_id ~= nil and target_id ~= "" then 
						local target = vRP.getUserSource({tonumber(target_id)})
						if target ~= nil then
							vRP.request({target, lang.hire.ask_player({GetPlayerName(player)}), 60, function(nplayer,ok)
								if ok then 
									local ngruppo = vRP.getGroupFiglio({gruppo})
									vRP.addUserGroup({tonumber(target_id),ngruppo})
									vRPclient.notify(player,{lang.common.agreed()})
								else
									vRPclient.notify(player,{lang.common.refused()})
								end
							end})
						end
					end
				end})
			end
		end)
	end
end}

local choice_licenzia = {function(player,choice) 
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		local gruppo = vRP.getUserGroupByType({user_id,"business"})
		local ngruppo = vRP.getGroupFiglio({gruppo})
		vRPclient.getNearestPlayers(player,{15},function(nplayers) 
			local user_list = ""
			for k,v in pairs(nplayers) do
				user_list = user_list .. "[" .. vRP.getUserId({k}) .. "]" .. GetPlayerName(k) .. " | "
			end 
			if user_list ~= "" then
				vRP.prompt({player, lang.common.near_players({user_list}),"",function(player,target_id) 
					if target_id ~= nil and target_id ~= "" then 
						local target = vRP.getUserSource({tonumber(target_id)})
						if target ~= nil then
							if vRP.hasGroup({tonumber(target_id),ngruppo}) then
								vRP.removeUserGroup({tonumber(target_id),ngruppo})
								vRPclient.notify(player,{lang.hire.fired({GetPlayerName(tonumber(target))})})
								vRPclient.notify(tonumber(target),{lang.hire.you_fired()})
							else
								vRPclient.notify(player,{lang.hire.not_employee()})
							end
						end
					end
				end})
			end
		end)
	end
end}

local choice_abbandona = {function(player,choice) 
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		vRP.request({player, lang.sell.close_down(), 60, function(player,ok)
			if ok then 
				local gruppo = vRP.getUserGroupByType({user_id,"business"})
				local name = vRP.getGroupName({gruppo})
				vRP.removeUserGroup({user_id,gruppo})
				SetStato(name,0)
				vRP.openMainMenu({player})
			end
		end})
	end
end}

local choice_pinchange = {function(player,choice)
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		if not vRP.hasPermission({user_id,"no.withdraw"}) then
			vRPcc.getOwnerBizName({user_id, function(business)
				vRPcc.cambia_PIN({business, player})
			end})		
		else
			vRPclient.notify(player,{lang.common.freezed_account()})
		end
	end
end}

local choice_saldo = {function(player,choice)
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		local business = vRPcc.getUserBizName({user_id})
		vRPcc.getBankBalance({business, function(amount)
			vRPclient.notify(player,{lang.common.account_statement({amount})})
		end})
	end
end}

local choice_paga_utente = {function(player,choice)
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		if not vRP.hasPermission({user_id,"no.withdraw"}) then
			vRPcc.pagaUtente({user_id, player})
		else
			vRPclient.notify(player,{lang.common.freezed_account()})
		end
	end
end}

local choice_trans_az_pers = {function(player,choice)
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		if not vRP.hasPermission({user_id,"no.withdraw"}) then
			vRPcc.trasferisciContoAzPers({user_id, player})
		else
			vRPclient.notify(player,{lang.common.freezed_account()})
		end
	end
end}

local choice_trans_pers_az = {function(player,choice)
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		if not vRP.hasPermission({user_id,"no.withdraw"}) then	
			vRPcc.trasferisciContoPersAz({user_id, player})
		else
			vRPclient.notify(player,{lang.common.freezed_account()})
		end
	end
end}

local conto_menu = {function(player,choice)
	local user_id = vRP.getUserId({player})
	local menu = {}
	menu.name = lang.menu.conto.name()
	menu.css = {top="75px",header_color="rgba(0,0,0,0.90)"}
	menu.onclose = function(player) vRP.openMainMenu({player}) end
	if vRP.hasPermission({user_id,"conto.v2"}) then
		menu[lang.menu.conto.pin_change()] = choice_pinchange
	end  
	if vRP.hasPermission({user_id,"conto.v2"}) then
		menu[lang.menu.conto.statement()] = choice_saldo
	end 
	if vRP.hasPermission({user_id,"conto.v1"}) then
		menu[lang.menu.conto.pay_user()] = choice_paga_utente
	end
	if vRP.hasPermission({user_id,"conto.v1"}) then
		menu[lang.menu.conto.transfer_ap()] = choice_trans_az_pers
	end
	if vRP.hasPermission({user_id,"conto.v1"}) then
		menu[lang.menu.conto.transfer_pa()] = choice_trans_pers_az
	end
	vRP.openMenu({player,menu})
end}

local business_menu = {function(player,choice)
	local user_id = vRP.getUserId({player})
	local menu = {}
	menu.name = lang.menu.business.name()
	menu.css = {top="75px",header_color="rgba(0,0,0,0.90)"}
	menu.onclose = function(player) vRP.openMainMenu({player}) end
	if vRP.hasPermission({user_id,"propr.aut"}) then
		menu[lang.menu.business.hire()] = choice_assumi
	end  
	if vRP.hasPermission({user_id,"propr.aut"}) then
		menu[lang.menu.business.fire()] = choice_licenzia
	end  
	if vRP.hasPermission({user_id,"propr.aut"}) then
		menu[lang.menu.business.close_down()] = choice_abbandona
	end
	vRP.openMenu({player,menu})
end}

vRP.registerMenuBuilder({"main", function(add, data)
	local player = data.player
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		local choices = {}
		if vRP.hasPermission({user_id,"propr.aut"}) then
			choices[lang.menu.business.name()] = business_menu
		end
		if vRP.hasPermission({user_id,"conto.v1"}) then
			choices[lang.menu.conto.name()] = conto_menu
		end
		add(choices)
	end
end})

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
	if first_spawn then
		for nome, data in pairs(blips) do
			BUclient.AggBlip(source,{data.x,data.y,data.z,605,69,data.title})
		end
	end
end)