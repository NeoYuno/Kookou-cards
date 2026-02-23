--The Deathly Ghost of Fled Dreams
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon from hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--Hand banish
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCondition(s.rmcon)
	e2:SetCost(s.rmcost)
	e2:SetOperation(s.rmop)
	e2:SetCountLimit(1,id+100)
	c:RegisterEffect(e2)
end
s.listed_names={94212438}
function s.spfilter(c)
	return c:IsFaceup()
		and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_FIEND)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(
		function(c) return c:IsFaceup() and c:IsCode(94212438) end,
		tp,LOCATION_SZONE,0,1,nil)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local opp=1-tp
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #hg==0 then return end
	Duel.ConfirmCards(tp,hg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=hg:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	if not tc then return end
	aux.RemoveUntil(tc,POS_FACEUP,REASON_EFFECT|REASON_TEMPORARY,PHASE_END,id,e,tp,function(ag,e,tp) Duel.SendtoHand(ag,nil,REASON_EFFECT) end)
end