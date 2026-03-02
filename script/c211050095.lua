--Undead Phantom Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),1,1,Synchro.NonTunerEx(Card.IsRace,RACE_ZOMBIE),1,99,s.exmatfilter)
	c:EnableReviveLimit()

	--Quick Synchro Summon using any Zombie on field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.syntg)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)

	--Opponent GY summon + Level change + negate (Opponent's turn)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.oppturn)
	e2:SetTarget(s.opp_sptg)
	e2:SetOperation(s.opp_spop)
	c:RegisterEffect(e2)

	--Treat as Non-Tuner for Zombie Synchro
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_NONTUNER)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetValue(function(e,sc) return sc:IsRace(RACE_ZOMBIE) end)
	c:RegisterEffect(e3)
end

function s.exmatfilter(c,scard,sumtype,tp)
	return c:IsRace(RACE_ZOMBIE,scard,sumtype,tp)
end

-- Quick Synchro Summon target
function s.matfilter(c)
	return c:IsRace(RACE_ZOMBIE)
		and c:IsType(TYPE_MONSTER)
		and ((c:IsFaceup() and c:IsLocation(LOCATION_MZONE)))
end

function s.tunerfilter(c)
    return c:IsType(TYPE_TUNER) or c:IsHasEffect(EFFECT_CAN_BE_TUNER) or c:IsHasEffect(EFFECT_NONTUNER)
end
--------------------------------------------------
-- Target
--------------------------------------------------
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg1=Duel.GetMatchingGroup(s.matfilter,tp,
		LOCATION_MZONE,LOCATION_MZONE,nil)

	local mg=mg1:Clone()

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
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()

	local mg1=Duel.GetMatchingGroup(s.matfilter,tp,
		LOCATION_MZONE,LOCATION_MZONE,nil)

	local mg=mg1:Clone()

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

	-- Send your materials
	Duel.SendtoGrave(mat,
		REASON_EFFECT+REASON_MATERIAL+REASON_SYNCHRO)

	sc:SetMaterial(mat)
	Duel.SpecialSummon(sc,
		SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
	sc:CompleteProcedure()
end

-- Opponent's turn condition
function s.oppturn(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

-- Opponent GY summon target
function s.opp_filter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,1-tp,false,false)
end
function s.opp_sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.opp_filter,tp,0,LOCATION_GRAVE,1,nil,e,tp) 
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_GRAVE)
end

-- Opponent GY summon operation
function s.opp_spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.opp_filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP) then
			-- Level change
			local lv=Duel.AnnounceLevel(tp,1,6)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- Negate effects
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		Duel.SpecialSummonComplete()
	end
end

-- Treat any face-up Zombie as Tuner for this Synchro
function s.syntunerop(e,tp,eg,ep,ev,re,r,rp,c,sc)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tg=Group.CreateGroup()
	for tc in aux.Next(g) do
		if tc:IsRace(RACE_ZOMBIE) then tg:AddCard(tc) end
	end
	return tg
end