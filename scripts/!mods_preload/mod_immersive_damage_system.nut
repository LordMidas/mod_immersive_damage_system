::ImmersiveDamageSystem <- {
	ID = "mod_immersive_damage",
	Version = "1.0.0",
	Name = "Immersive Damage System (IDS)"
};

::ImmersiveDamageSystem.MH <- ::Hooks.register(::ImmersiveDamageSystem.ID, ::ImmersiveDamageSystem.Version, ::ImmersiveDamageSystem.Name);
::ImmersiveDamageSystem.MH.require("mod_msu");

::ImmersiveDamageSystem.MH.queue(">mod_msu", function () {

	foreach (file in ::IO.enumerateFiles("mod_immersive_damage_system"))
	{
		::include(file);
	}

	::ImmersiveDamageSystem.Mod <- ::MSU.Class.Mod(::ImmersiveDamageSystem.ID, ::ImmersiveDamageSystem.Version, ::ImmersiveDamageSystem.Name);
	::ImmersiveDamageSystem.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/LordMidas/mod_immersive_damage_system");
	::ImmersiveDamageSystem.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	local page = ::ImmersiveDamageSystem.Mod.ModSettings.addPage("General");
	page.addBooleanSetting("IDS_Enable", true, "Enable IDS", "Enables the Immersive Damage System which scales damage reduction based on hit chance.")
	.addBeforeChangeCallback(function( _newValue) { ::ImmersiveDamageSystem.Config.IsEnabled = _newValue; });

	page.addRangeSetting("IDS_MinReduction", ::ImmersiveDamageSystem.Config.MaxDamageMult * 100 - 100, 0, 100, 1, "Minimum Reduction (%)", "The minimum damage reduction that IDS can apply to an attack.")
	.addBeforeChangeCallback(function( _newValue ) { ::ImmersiveDamageSystem.Config.MaxDamageMult = 1.0 - _newValue / 100.0; });

	page.addRangeSetting("IDS_MaxReduction", 100 - ::ImmersiveDamageSystem.Config.MinDamageMult * 100, 0, 100, 1, "Maximum Reduction (%)", "The maximum damage reduction that IDS can apply to an attack.")
	.addBeforeChangeCallback(function( _newValue ) { ::ImmersiveDamageSystem.Config.MinDamageMult = 1.0 - _newValue / 100.0; });

	page.addRangeSetting("IDS_MinHitChance", ::ImmersiveDamageSystem.Config.MinHitChance, 0, 100, 1, "Lower Hit-Chance Threshold", "Any hit chance below this has the same damage reduction spread as this hit chance.")
	.addBeforeChangeCallback(function( _newValue ) { ::ImmersiveDamageSystem.Config.MinHitChance = _newValue; });

	page.addRangeSetting("IDS_MaxHitChance", ::ImmersiveDamageSystem.Config.MaxHitChance, 0, 100, 1, "Upper Hit-Chance Threshold", "Any hit chance above this has the same damage reduction spread as this hit chance.")
	.addBeforeChangeCallback(function( _newValue ) { ::ImmersiveDamageSystem.Config.MaxHitChance = _newValue; });

	page.addRangeSetting("IDS_ChanceNoReduction", ::ImmersiveDamageSystem.Config.ChanceNoReduction, 0, 100, 1, "Full Damage Chance (%)", "All hits have this much chance to have no damage reduction from IDS, regardless of the hit-chance.")
	.addBeforeChangeCallback(function( _newValue ) { ::ImmersiveDamageSystem.Config.ChanceNoReduction = _newValue; });

	page.addRangeSetting("IDS_ChanceCriticalFailure", ::ImmersiveDamageSystem.Config.ChanceCriticalFailure, 0, 100, 1, "Critical Failure Chance (%)", "All hits have this much chance to have the maximum damage reduction from IDS, regardless of the hit-chance.")
	.addBeforeChangeCallback(function( _newValue ) { ::ImmersiveDamageSystem.Config.ChanceCriticalFailure = _newValue; });

	page.addRangeSetting("IDS_MaxDamageHitChance", ::ImmersiveDamageSystem.Config.MaxDamageHitChance, 0, 100, 1, "Max Damage Hit-Chance", "Hit-chance at this value and above will never get any damage reduction from IDS.")
	.addBeforeChangeCallback(function( _newValue ) { ::ImmersiveDamageSystem.Config.MaxDamageHitChance = _newValue; });

	page.addRangeSetting("IDS_MinDamageHitChance", ::ImmersiveDamageSystem.Config.MinDamageHitChance, 0, 100, 1, "Min Damage Hit-Chance", "Hit-chance at this value and below will always get the maximum damage reduction from IDS.")
	.addBeforeChangeCallback(function( _newValue ) { ::ImmersiveDamageSystem.Config.MinDamageHitChance = _newValue; });

	page.addButtonSetting("IDS_ResetDefault", "Reset to Defaults", "Reset", "Reset all IDS settings to their Default values")
	.addBeforeChangeCallback(function() { ::ImmersiveDamageSystem.Mod.ModSettings.resetSettings(); });
});
