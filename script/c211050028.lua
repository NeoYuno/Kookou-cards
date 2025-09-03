--Robe of the Dark Magician
local s,id=GetID()
function s.initial_effect(c)
	--Activate: Draw 2 then discard a Dark Magician card / mentioner
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_DARK_MAGICIAN}
s.listed_series={0x10a2}

--Filter for discard
function s.disfilter(c)
	return c:IsDiscardable() and c:IsSetCard(0x10a2) or c:ListsCode(CARD_DARK_MAGICIAN)
end

--Target
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

--Operation
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,2,REASON_EFFECT)<2 then return end
	Duel.ShuffleHand(tp)
	--Check if discardable card exists
	if Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.SendtoGrave(g,REASON_DISCARD+REASON_EFFECT)
	else
		--If not, discard whole hand
		local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		if #hg>0 then
			Duel.SendtoGrave(hg,REASON_DISCARD+REASON_EFFECT)
		end
	end
end
