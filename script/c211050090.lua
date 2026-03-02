--Undead Clown
local s,id=GetID()

function s.initial_effect(c)

	--------------------------------------------------
	-- Special Summon from hand
	--------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	--------------------------------------------------
	-- GY revival + Level change
	--------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)

	--------------------------------------------------
	-- Opponent Synchro Summon
	--------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.sctg)
	e3:SetOperation(s.scop)
	c:RegisterEffect(e3)
    --A monster Synchro Summoned using this card as material gains an effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return (r&REASON_SYNCHRO)==REASON_SYNCHRO end)
	e4:SetOperation(s.effop)
	c:RegisterEffect(e4)
end

--------------------------------------------------
-- Condition: control Level 4+ Zombie
--------------------------------------------------
function s.zfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(4)
end

function s.spcon1(e,tp)
	return Duel.IsExistingMatchingCard(s.zfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--------------------------------------------------
-- GY revival condition
--------------------------------------------------
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
		and eg:IsExists(function(c)
			return c:IsRace(RACE_ZOMBIE) and c:IsSummonPlayer(1-tp)
		end,1,nil)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=eg:Filter(function(c)
			return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
				and c:IsSummonPlayer(1-tp)
		end,nil)
		local tc=g:GetFirst()
		if tc and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local lv=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
			local newlv=(lv==0) and 4 or 8
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(newlv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end

--------------------------------------------------
-- Opponent Monster Synchro
--------------------------------------------------
function s.synfilter(c,mc,tp)
	return c:IsRace(RACE_ZOMBIE)
		and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(nil,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and c:IsLevel(mc:GetLevel()+c:GetLevel())
end

function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		if not c:IsType(TYPE_TUNER) then return false end
		local g=Duel.GetMatchingGroup(
			function(c) return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) end,
			tp,0,LOCATION_MZONE,nil)
		return g:IsExists(function(tc)
			return Duel.IsExistingMatchingCard(
				function(sc)
					return sc:IsRace(RACE_ZOMBIE)
						and sc:IsType(TYPE_SYNCHRO)
						and sc:IsLevel(c:GetLevel()+tc:GetLevel())
						and sc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
				end,
				tp,LOCATION_EXTRA,0,1,nil)
		end,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not c:IsType(TYPE_TUNER) then return end

	local g=Duel.GetMatchingGroup(
		function(c) return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) end,
		tp,0,LOCATION_MZONE,nil)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end

	local lv=c:GetLevel()+tc:GetLevel()

	local sg=Duel.SelectMatchingCard(tp,
		function(sc)
			return sc:IsRace(RACE_ZOMBIE)
				and sc:IsType(TYPE_SYNCHRO)
				and sc:IsLevel(lv)
				and sc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		end,
		tp,LOCATION_EXTRA,0,1,1,nil)

	local sc=sg:GetFirst()
	if not sc then return end
    local syng=Group.FromCards(c,tc)
	Duel.SendtoGrave(syng,REASON_EFFECT+REASON_MATERIAL+REASON_SYNCHRO)
    Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,true,true,POS_FACEUP)
    sc:CompleteProcedure()
    -- Grant Zombie conversion effect
	local e1=Effect.CreateEffect(sc)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetValue(RACE_ZOMBIE)
	sc:RegisterEffect(e1,true)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if not rc:IsType(TYPE_EFFECT) then
		--It becomes an Effect Monster if it's not one already
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_ADD_TYPE)
		e0:SetValue(TYPE_EFFECT)
		e0:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(e0,true)
	end
	-- Grant Zombie conversion effect
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetValue(RACE_ZOMBIE)
	rc:RegisterEffect(e1,true)
end