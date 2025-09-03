--Dark Magician of Sage
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
	--Fusion Summon condition
	Fusion.AddProcMix(c,true,true,CARD_DARK_MAGICIAN,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),Card.IsLevelBelow,4)
	--Alternative Summon by sending materials on field (Fusion Summon treated)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(Quick Effect) Send "Dark Magician" Spell/Trap to GY, copy its effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(s.cptg)
	e2:SetOperation(s.cpop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_DARK_MAGICIAN}
s.material_setcode={0x10a2}

--=== (1) Alt Summon: send materials from field ===--
function s.spfilter1(c,tp)
	return c:IsCode(CARD_DARK_MAGICIAN) and c:IsControler(tp) and c:IsOnField()
end
function s.spfilter2(c,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(4) and c:IsControler(tp) and c:IsOnField()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.spfilter1,1,nil,tp)
		and Duel.CheckReleaseGroup(tp,s.spfilter2,1,nil,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g1=Duel.SelectReleaseGroup(tp,s.spfilter1,1,1,nil,tp)
	local g2=Duel.SelectReleaseGroup(tp,s.spfilter2,1,1,nil,tp)
	g1:Merge(g2)
	Duel.Release(g1,REASON_COST+REASON_FUSION+REASON_MATERIAL)
    e:GetHandler():CompleteProcedure()
end

--=== (2) Quick Effect: send Spell/Trap that mentions "Dark Magician" and copy effect ===--
function s.cpfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:ListsCode(CARD_DARK_MAGICIAN) and c:IsAbleToGrave()
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cpfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		--Apply the effect of that card
		local te=tc:CheckActivateEffect(false,true,true)
		if te then
			e:SetCategory(te:GetCategory())
			e:SetProperty(te:GetProperty())
			local tg=te:GetTarget()
			local op=te:GetOperation()
			if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
			if op then op(e,tp,eg,ep,ev,re,r,rp) end
		end
	end
end
