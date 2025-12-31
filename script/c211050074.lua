--Obliterate!!! Unleashed
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- Exodia monsters cannot be targeted by opponent
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.tgtg)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- Banish face-down
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rmcon)
    e2:SetCost(Cost.PayLP(2000))
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end

function s.tgtg(e,c)
	return c:IsSetCard(SET_EXODIA)
end

function s.exodiafilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_EXODIA)
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.exodiafilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.rmfilter(c)
	return c:IsAbleToRemove()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end
