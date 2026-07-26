class_name PriceSection
extends TooltipSection

var label_path = "res://scripts/tooltip/sections/labels/PriceSectionLabel.tscn"

func applies_to(item: Item) -> bool:
	var vendor_inventory = InventorySystem.get_inventory("vendor")
	# Primero revisa si el valor es mayor a 0, luego si el vendedor existe, y por último si está visible
	return item.get_worth() > 0 and vendor_inventory != null and vendor_inventory.visible

func append(item: Item, tooltip: ItemTooltip) -> void:
	tooltip.add_spacer()
	var currency_item = item.currency_item if item.currency_item else InventorySystem.get_currency_item()
	var currency_path = currency_item.icon.resource_path
	var currency_name = currency_item.name

	var color = "#FFFFFF"
	if item.vendor_item:
		var player_inventory = InventorySystem.get_player_inventory()
		var currency = 0
		if item.currency_item:
			currency = player_inventory.get_item_count(item.currency_item.id)
		else:
			currency = player_inventory.get_currency_amount()
		if currency < item.get_worth():
			color = "#FF5555"

	tooltip.add_line("[color=%s]%dx [img height=16]%s[/img] %s[/color]" % [color, item.get_worth(), currency_path, currency_name], label_path)
