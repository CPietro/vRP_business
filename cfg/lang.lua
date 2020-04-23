local lang = {
	buy = {
		confirmation_message = "^1{1}^3 is now ^1{2}^3 for ^1{3}^3$",
		congratulation = "Congratulations for buying ~b~{1} ~h~manage it at your best!",
		not_enough_money = "~r~You don't have enough money!",
		already_bought = "~r~Business already bought!",
		already_owned = "~r~This business is already yours.",
		already_owned_by_you = "~r~You already are {1}"
	},
	sell = {
		offered_price = "Price to offer:",
		ask_sale = "{1} wants to sell you his business ({2}) for {3}",
		congratulation = "~g~Congratulations for the purchase...",
		close_down = "Are you sure you want to close your business down?"
	},
	hire = {
		ask_player = "{1} wants to hire you in his business...",
		fired = "{1} doesn't work for you anymore...",
		you_fired = "~r~You are fired...",
		not_employee = "~r~This player isn't an employee of yours"
	},
	common = {
		near_players = "Near players: {1}",
		agreed = "~g~The player accepted your offer",
		refused = "~r~The player declined your offer",
		no_players_near = "~r~No players near...",
		player_not_enough_money = "~r~The player doesn't have enough money...",
		freezed_account = "You bank account is frozen.",
		account_statement = "The business' account balance is ~g~{1}$~w~."
	},
	menu = {
		conto = {
			name = "Business account",
			pin_change = "PIN change",
			statement = "Show balance",
			pay_user = "Pay user",
			transfer_ap = "Transfer from personal business to personal",
			transfer_pa = "Transfer from personal account to business"
		},
		business = {
			name = "Business",
			hire = "Hire",
			fire = "Fire",
			close_down = "Close down"
		}
	}
}

return lang
