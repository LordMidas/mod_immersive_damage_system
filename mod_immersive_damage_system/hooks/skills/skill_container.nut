::ImmersiveDamageSystem.MH.hook("scripts/skills/skill_container", function(q) {
	q.m.ImmersiveDamageSystem_Mult <- 1.0;
	q.m.ImmersiveDamageSystem_Roll <- 100;

	q.buildPropertiesForUse = @(__original) function( _caller, _targetEntity )
	{
		local ret = __original(_caller, _targetEntity);

		if (_targetEntity == null || !_caller.isAttack() || this.m.ImmersiveDamageSystem_Roll == -1 || !::ImmersiveDamageSystem.Config.IsEnabled)
		{
			return ret;
		}

		this.m.ImmersiveDamageSystem_Mult = ::ImmersiveDamageSystem.Config.MaxDamageMult;

		this.m.ImmersiveDamageSystem_Roll = -1;
		local hitChance = _caller.getHitchance(_targetEntity);
		this.m.ImmersiveDamageSystem_Roll = 0;

		if (hitChance >= ::ImmersiveDamageSystem.Config.MaxDamageHitChance)
			return ret;

		if (hitChance <= ::ImmersiveDamageSystem.Config.MinDamageHitChance)
		{
			this.m.ImmersiveDamageSystem_Mult = ::ImmersiveDamageSystem.Config.MinDamageMult;
			return ret;
		}

		this.m.ImmersiveDamageSystem_Roll = ::Math.rand(1, 100);
		if (this.m.ImmersiveDamageSystem_Roll > 100 - ::ImmersiveDamageSystem.Config.ChanceCriticalFailure)
		{
			this.m.ImmersiveDamageSystem_Mult = ::ImmersiveDamageSystem.Config.MinDamageMult;
		}
		else
		{
			local half = ::ImmersiveDamageSystem.Config.ChanceNoReduction / 2.0;
			if (this.m.ImmersiveDamageSystem_Roll < 50 - half || this.m.ImmersiveDamageSystem_Roll > 50 + half)
			{
				local stdev = ::Math.min(::ImmersiveDamageSystem.Config.MaxHitChance, ::Math.max(::ImmersiveDamageSystem.Config.MinHitChance, hitChance));
				this.m.ImmersiveDamageSystem_Mult = ::Math.maxf(::ImmersiveDamageSystem.Config.MinDamageMult, ::MSU.Math.normalDistNorm(this.m.ImmersiveDamageSystem_Roll, 50, stdev));
			}
		}

		ret.DamageTotalMult *= this.m.ImmersiveDamageSystem_Mult;
		return ret;
	}

	q.onTargetHit = @(__original) function( _caller, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		__original(_caller, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor);

		if (!_targetEntity.isAlive() || _targetEntity.isDying() || this.getActor().isHiddenToPlayer() || !_targetEntity.getTile().IsVisibleForPlayer || (_damageInflictedHitpoints == 0 && _damageInflictedArmor == 0) || !::ImmersiveDamageSystem.Config.IsEnabled)
		{
			return;
		}

		local goodness = (this.m.ImmersiveDamageSystem_Mult - ::ImmersiveDamageSystem.Config.MinDamageMult) / (::ImmersiveDamageSystem.Config.MaxDamageMult - ::ImmersiveDamageSystem.Config.MinDamageMult);

		local fluff = "";
		foreach (threshold in ::ImmersiveDamageSystem.Config.GoodnessThresholds)
		{
			if (goodness >= threshold.Threshold)
			{
				fluff = _caller.isRanged() ? threshold.FluffRanged : threshold.FluffMelee;
				break;
			}
		}

		local damageString = this.m.ImmersiveDamageSystem_Mult < 0.99 ? ::Math.round(this.m.ImmersiveDamageSystem_Mult * 100) + "%" : "full";
		local fluffString = format("%s dealing %s damage!", fluff.len() > 0 ? fluff[::Math.rand(0, fluff.len() - 1)] : "", this.m.ImmersiveDamageSystem_Mult < ::ImmersiveDamageSystem.Config.MaxDamageMult * 0.5 ? ::MSU.Text.colorRed(damageString) : ::MSU.Text.colorGreen(damageString));
		fluffString = ::MSU.String.replace(fluffString, "targetName", _targetEntity.getName());

		::Tactical.EventLog.logEx(::Const.UI.getColorizedEntityName(this.getActor()) + fluffString);
	}
});
