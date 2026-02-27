--Death's Spirit Message "E"
local s,id=GetID()
function s.initial_effect(c)
	--------------------------------------------------
	-- Target 1 DARK Fiend GY + 1 opponent monster; banish both
	--------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--------------------------------------------------
	-- Cannot be banished except by Destiny Board
	--------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_ALL)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetValue(s.remval)
	c:RegisterEffect(e2)
end
s.listed_names={94212438}
function s.gyfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_FIEND)
		and c:IsAbleToRemove()
end

function s.opfilter(c)
	return c:IsAbleToRemove()
end

--------------------------------------------------
-- Target
--------------------------------------------------
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return (chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gyfilter(chkc))
			or (chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.opfilter(chkc))
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingTarget(s.opfilter,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectTarget(tp,s.opfilter,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,2,0,0)
end

--------------------------------------------------
-- Operation
--------------------------------------------------
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

--------------------------------------------------
-- Cannot be banished except by Destiny Board
--------------------------------------------------
function s.remval(e,re,r,rp)
	if not re then return true end
	return not re:GetHandler():IsCode(94212438) -- Destiny Board ID
end