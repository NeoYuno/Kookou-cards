--Undead Drake
local s,id=GetID()

function s.initial_effect(c)

	--------------------------------------------------
	-- Send Level 6 or lower Zombie from Deck to GY
	--------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	--------------------------------------------------
	-- Quick Synchro Summon
	--------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sctg)
	e2:SetOperation(s.scop)
	c:RegisterEffect(e2)
end

--------------------------------------------------
-- Foolish filter
--------------------------------------------------
function s.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE)
		and c:IsLevelBelow(6)
		and c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--------------------------------------------------
-- Material filter
--------------------------------------------------
--------------------------------------------------
-- Material filters
--------------------------------------------------
function s.matfilter(c)
	return c:IsRace(RACE_ZOMBIE)
		and c:IsType(TYPE_MONSTER)
		and ((c:IsFaceup() and c:IsLocation(LOCATION_MZONE))
			or c:IsLocation(LOCATION_HAND))
end

function s.gyfilter(c)
	return c:IsRace(RACE_ZOMBIE)
		and c:IsType(TYPE_MONSTER)
end

function s.tunerfilter(c)
    return c:IsType(TYPE_TUNER) or c:IsHasEffect(EFFECT_CAN_BE_TUNER) or c:IsHasEffect(EFFECT_NONTUNER)
end
--------------------------------------------------
-- Target
--------------------------------------------------
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg1=Duel.GetMatchingGroup(s.matfilter,tp,
		LOCATION_MZONE+LOCATION_HAND,0,nil)
	local mg2=Duel.GetMatchingGroup(s.gyfilter,tp,
		0,LOCATION_GRAVE,nil)

	local mg=mg1:Clone()
	mg:Merge(mg2)

	if chk==0 then
		return Duel.IsExistingMatchingCard(function(sc)
			if not (sc:IsRace(RACE_ZOMBIE)
				and sc:IsType(TYPE_SYNCHRO)) then
				return false
			end

			return mg:CheckWithSumEqual(Card.GetLevel,
				sc:GetLevel(),2,99)
		end,tp,LOCATION_EXTRA,0,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

--------------------------------------------------
-- Operation
--------------------------------------------------
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()

	local mg1=Duel.GetMatchingGroup(s.matfilter,tp,
		LOCATION_MZONE+LOCATION_HAND,0,nil)
	local mg2=Duel.GetMatchingGroup(s.gyfilter,tp,
		0,LOCATION_GRAVE,nil)

	local mg=mg1:Clone()
	mg:Merge(mg2)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,function(sc)
		return sc:IsRace(RACE_ZOMBIE)
			and sc:IsType(TYPE_SYNCHRO)
			and mg:CheckWithSumEqual(Card.GetLevel,
				sc:GetLevel(),2,99)
	end,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()

	if not sc then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local mat=mg:SelectWithSumEqual(tp,
		Card.GetLevel,
		sc:GetLevel(),2,99)

	if not mat then return end

	-- Must contain exactly 1 Tuner
	if mat:FilterCount(s.tunerfilter,nil)<1 then
		return
	end

	-- Split opponent GY materials
	local oppgy=mat:Filter(function(c)
		return c:IsLocation(LOCATION_GRAVE)
			and c:IsControler(1-tp)
	end,nil)

	local rest=mat-oppgy

	-- Banish opponent GY materials
	if #oppgy>0 then
		Duel.Remove(oppgy,POS_FACEUP,
			REASON_EFFECT+REASON_MATERIAL+REASON_SYNCHRO)
	end

	-- Send your materials
	Duel.SendtoGrave(rest,
		REASON_EFFECT+REASON_MATERIAL+REASON_SYNCHRO)

	sc:SetMaterial(mat)
	Duel.SpecialSummon(sc,
		SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
	sc:CompleteProcedure()
end