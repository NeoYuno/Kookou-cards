--Death Necrofear
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
    --Place
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCost(s.cost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	e2:SetCountLimit(1,{id,1})
	c:RegisterEffect(e2)
end
s.listed_names={94212438}
function s.check(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==3 and not sg:IsContains(e:GetHandler()) 
end
function s.spconfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsMonster()
		and c:IsAbleToGraveAsCost() and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spconfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_DECK,0,c)
	return aux.SelectUnselectGroup(g,e,tp,3,3,s.check,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetMatchingGroup(s.spconfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_DECK,0,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,s.check,1,tp,HINTMSG_TOGRAVE)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.dbfilter(c)
	return c:IsCode(94212438) and not c:IsForbidden()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.dbfilter,tp,
				LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,
				0,1,nil)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.dbfilter,tp,
		LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,
		0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end