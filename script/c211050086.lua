--Death's Spirit Message "V"
local s,id=GetID()
function s.initial_effect(c)
	--------------------------------------------------
	-- Activate: Choose 1 effect
	--------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
end
s.listed_names={94212438}
function s.tdfilter(c)
	return c:IsAbleToDeck()
end

function s.gyfilter(c)
	return c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
	local b2=Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil)

	if chk==0 then return b1 or b2 end

	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,
			aux.Stringid(id,0), -- Shuffle GY to Deck
			aux.Stringid(id,1)) -- Return banished to GY
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(op)

	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectTarget(tp,s.tdfilter,tp,
			LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectTarget(tp,s.gyfilter,tp,
			LOCATION_REMOVED,LOCATION_REMOVED,1,3,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end

	if op==0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	else
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
