--Red-Eyes Ultimate Black Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Fusion summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,74677422,aux.FilterBoolFunction(Card.IsSetCard,0x3b),aux.FilterBoolFunction(Card.IsSetCard,0x3b))
	--Banish 1 card (Ignition or Quick if 2+ Red-Eyes Black Dragon used)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	local e1q=e1:Clone()
	e1q:SetType(EFFECT_TYPE_QUICK_O)
	e1q:SetCode(EVENT_FREE_CHAIN)
	e1q:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1q:SetCondition(s.rmcon)
	c:RegisterEffect(e1q)
	--Unaffected if 3+ Red-Eyes Black Dragon used
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetCondition(s.immcon)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	--Special Summon any Extra Deck Red-Eyes if leaves field by opponent
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.material_setcode={0x3b}
s.listed_names={74677422} -- Red-Eyes Black Dragon
s.listed_series={0x3b}

-- banish target
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,LOCATION_ONFIELD,LOCATION_ONFIELD)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- Quick Effect if 2+ Red-Eyes Black Dragon used
function s.rmcon(e)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	return mg and mg:IsExists(Card.IsOriginalCode,2,nil,74677422)
end

-- immunity if 3+ Red-Eyes Black Dragon used
function s.immcon(e)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	return mg and mg:IsExists(Card.IsOriginalCode,3,nil,74677422)
end
function s.immval(e,te)
	return te:IsActiveType(TYPE_MONSTER) or te:IsActiveType(TYPE_TRAP)
end

-- if leaves field by opponent
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3b) and not c:IsCode(id) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		-- Proper summon type
		local stype=0
		if tc:IsType(TYPE_FUSION) then stype=SUMMON_TYPE_FUSION
		elseif tc:IsType(TYPE_SYNCHRO) then stype=SUMMON_TYPE_SYNCHRO
		elseif tc:IsType(TYPE_XYZ) then stype=SUMMON_TYPE_XYZ
		elseif tc:IsType(TYPE_LINK) then stype=SUMMON_TYPE_LINK end
		if Duel.SpecialSummon(tc,stype,tp,tp,false,false,POS_FACEUP)>0 and tc:IsType(TYPE_XYZ) then
			Duel.Overlay(tc,Group.FromCards(c))
		end
	end
end
