# vRP Business

## Description
  With this script you can set up businesses which will be owned by players. You can buy a company, hire people, fire them and even sell the company. Since this script has [vRP_companyaccs](https://github.com/CPietro/vRP_companyaccs) as a dependency, each business will also have a bank account to store their money in, and it'll also grow over time thanks to interest rates (which can be set upon your liking!).\
  Each company has their indipendent permission, so you can create missions or menus to do stuff for them. For example a dealership where only employees can buy cars, a gun store or a bank.

## Pictures
<details><summary>SHOW</summary>
<p>

![Image1](https://i.postimg.cc/MHjSK1nM/image.png)\
![Image2](https://i.postimg.cc/Jz3BzkX2/image.png)\
![Image3](https://i.postimg.cc/C1rcrtLk/image.png)
</p>
</details>

## Dependencies
 #### Mandatory
 * [vRP_cards](https://github.com/CPietro/vRP_cards) - Cards for players to buy stuff with them;
 * [vRP_companyaccs](https://github.com/CPietro/vRP_companyaccs) - Bank accounts for [vRP_business](#vrp-business);
 * [vRP_items](https://github.com/CPietro/vRP_items) - Custom items to do stuff, such as personalized licenses, debit cards...;
 * [vRP_job_display](https://github.com/CPietro/vRP_job_display) - Modified version of the standard vrp_job_display script;
 * [Changes](#changes-to-vrp-mandatory) - Mandatory modifications to vRP;

 #### Optionals

## Installation
  1. [IMPORTANT!] Install the dependencies first;
  2. Move the [vrp_business](#vrp-business) folder to your ```resources``` directory (the folder name must be all lowercase characters);
  3. Add "```start vrp_business```" to your server.cfg file;
  4. Make any changes you like to the files in the cfg folder;
  5. Enjoy!

## Changes to vRP (mandatory)
  * Replace the ```vrp\modules\group.lua``` file with [this](https://github.com/CPietro/vRP_misc_files/blob/master/group.lua) one;

  * Add the owner and employee groups as written below to ```vrp\cfg\groups.lua```, for every business you want to add you must do the same thing:
    <details><summary>SHOW</summary>

    ```lua
    ["Bank Director"] = {
        _config = { gtype = "business", figlio = "Bank Employee", name = "bank",
            onspawn = function(player) vRPclient.notify(player,{"You are the bank director."}) end
        },
        "propr.aut",
        "propr.banca_tax",
        "banca.vehicle",
        "propr.banca_money",
        "banca.mission",
        "banca.menu",
        "banca.cassa",
        "conto.v2",
        "conto.v1",
        "banca.pos"
    },

    ["Bank Employee"] = {
            _config = { gtype = "business",
            onspawn = function(player) vRPclient.notify(player,{"You are a bank employee."}) end
        },
        "dip.aut",
        "banca.vehicle",
        "banca.menu",
        "banca.cassa",
        "banca.mission",
        "conto.v1",
        "banca.pos"
    },
    ```
    </details>

## Instructions
  * To add a new company you must add it to the ```cfg.blips``` table, situated in the ```vrp_business\cfg\config.lua``` file, and also to the ```blips``` table in ```vrp_business\client.lua```:
    <details><summary>SHOW</summary>
    
    ```lua
    ["bank"] = {title="Pacific Standard", prezzo= 2000000, gruppo="Bank Director", x=263.72836303711,y=223.23931884766,z=101.68327331543},
    ```
    "bank" -> This is the internal name of the business, it won't be shown in game.\
    title -> This is the real name of the business.\
    prezzo -> The price a player pays to buy the company.\
    gruppo -> The group that's the owner of the company, only one player should have it. You must add it to the ```vrp\cfg\groups.lua``` file as written [above](#changes-to-vrp-mandatory).\
    x,y,z -> The coordinates where players will be able to buy the business.
    </details>

    Add the owner and employee groups to the ```vrp\cfg\groups.lua``` file, being careful to change the permissions (except for conto.v1, conto.v2, propr.aut and dip.aut, those should always stay the same!).

## License
  ```
  vRP Business
  Copyright (C) 2020  CPietro - Discord: @TBGaming#9941

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published
  by the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
  ```
