# 🚓 zaylf4-vehicleinteractions

A FiveM vehicle interaction menu for emergency vehicles, built on [`ox_lib`](https://github.com/overextended/ox_lib). From the driver's seat, players can open or close individual doors, switch liveries, turn vehicle extras on and off, and change the licence plate design. Every change shows up on the vehicle straight away.

---

## 🖼️ Preview

### Main Menu

> The main menu with the Doors, Liveries, Extras and Plates categories.

<img src="https://github.com/user-attachments/assets/778d3b4d-a773-4c86-8578-459bcadbb70c" width="391">


<br><br>

> Options for all other sub menus for vehicle interactions

<br>


<table>
<tr>
<td valign="top">

### Doors Menu

<img src="https://github.com/user-attachments/assets/6d8f1df7-fbcf-4d91-8de6-fe24d5a77838" width="391">

</td>
<td valign="top">

### Liveries Menu

<img src="https://github.com/user-attachments/assets/59a22309-5a18-432a-8167-c6b2848bda86" width="391">

### Extras Menu

<img src="https://github.com/user-attachments/assets/8a659d87-1dde-407b-b0b1-7c17b4d6499a" width="391">

### Plates Menu

<img src="https://github.com/user-attachments/assets/a91539a0-1d20-4026-9cf1-6a9f6386c109" width="391">

</td>
</tr>
</table>


---

## 📦 Requirements

- FiveM server
- [`ox_lib`](https://github.com/overextended/ox_lib), for the menu and notifications
- *Optional:* game build **3095** or newer (`sv_enforceGameBuild 3095`), only if you want the extra plate designs that are commented out in the config

Works with any framework, or none. The script doesn't use QBCore, ESX or Qbox.

---

## 📁 Installation

1. Download or clone the repository.
2. Place `zaylf4-vehicleinteractions` into your server's `resources` folder.
3. Add the resource to `server.cfg`, **after** `ox_lib`:

```
ensure ox_lib
ensure zaylf4-vehicleinteractions
```

4. Restart your server.

---

## 🚀 Usage

Get in the **driver's seat** of an **emergency class vehicle** and open the menu in one of these ways:

- **`F5`**, the default keybind (players can rebind it under *Settings → Key Bindings → FiveM*)
- **`/vehmenu`** in chat
- The **`zaylf4-vehmenu:client:openmenu`** client event, from another resource (a radial menu, for example):

```lua
TriggerEvent('zaylf4-vehmenu:client:openmenu')
```

From the main menu:

- **Doors**: toggle each door the vehicle has (front and rear doors, hood, trunk, back doors, and the bomb bay on aircraft that have one). **Toggle All Doors** closes every door if any is open, and otherwise opens them all.
- **Liveries**: use `←` / `→` to scroll through liveries, and the vehicle updates as you scroll. Covers native liveries, mod kit liveries (slot 48, which many add-on vehicles use) and roof liveries. Only the types the vehicle supports are shown.
- **Extras**: turn each extra the vehicle has on or off.
- **Plates**: use `←` / `→` to scroll through plate designs, and the plate updates as you scroll.

Use `↑` / `↓` to move, `Enter` to select or toggle, and `Backspace` / `Esc` to go back. The menu closes automatically if you leave the vehicle or the driver's seat.

---

## ⚙️ Configuration

All settings are in [`config.lua`](config.lua):

- **`Config.Command`**: the chat command that opens the menu (default `'vehmenu'`).
- **`Config.DefaultKey`**: the default keybind for the command (default `'F5'`). Set to `''` for no default key.
- **`Config.DriverOnly`**: only the driver can open the menu (default `true`).
- **`Config.EmergencyOnly`**: only works in emergency class vehicles, `VC_EMERGENCY` / class 18 (default `true`). Set to `false` to allow any vehicle.
- **`Config.MenuPosition`**: where the menu appears on screen: `'top-left'`, `'top-right'`, `'bottom-left'` or `'bottom-right'`.
- **`Config.Doors`**: the label shown for each door index (0–7). Doors that don't exist on the vehicle are hidden automatically.
- **`Config.PlateTypes`**: the plate designs listed in the menu, each with an `index` (the plate type ID) and a `label`. Designs 6–12 (eCola, Las Venturas, Liberty City, LS Car Meet, LS Panic, LS Pounders and Sprunk) are commented out because they need game build 3095 or newer.

> **Note for add-on vehicles:** a vehicle counts as an emergency vehicle only if its `vehicles.meta` has `<vehicleClass>VC_EMERGENCY</vehicleClass>`. If your add-on police cars use another class, either fix the meta or set `Config.EmergencyOnly = false`.

---

## 🔍 Features

- **Built on `ox_lib`**: keyboard menus that don't take mouse focus, so you can keep driving while you use them.
- **Only shows what the vehicle has**: missing doors, extras and livery types are hidden instead of listed as empty options.
- **Live previews**: liveries and plates change on the vehicle as you scroll, before you confirm anything.
- **Three kinds of livery**: native liveries, mod kit liveries (slot 48) and roof liveries, using the game's livery names where they exist.
- **Correct extras state**: some extras switch each other off, so the menu refreshes when that happens and every checkbox matches the vehicle.
- **Bomb bay support**: aircraft with a bomb bay get their own toggle in the Doors menu.
- **No accidental key presses**: while the menu is open it blocks the phone, cellphone navigation and weapon scrolling, which share keys with the menu controls.
- **Configurable**: command, keybind, menu position, driver-only mode, emergency-only mode, door labels and plate list are all in `config.lua`.

---

## 🧩 Use Cases

- Police, EMS and fire vehicles on roleplay servers where officers set their own liveries, lightbars and equipment extras
- Opening trunks and doors for scenes, traffic stops and equipment
- Switching between marked, unmarked and department liveries without a mechanic

---

## 👤 Author

Developed by **Zayed**. If this resource helps you, consider ⭐ starring the repository!

---

## 📄 License

This script is provided for public use. Reselling or claiming ownership is not permitted.
