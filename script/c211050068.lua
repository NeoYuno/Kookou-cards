-- Kaiju Fierce Battle
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    -------------------------------------------------
    -- Activate from hand if you control a Kaiju
    -------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetCondition(s.handcon)
    c:RegisterEffect(e1)

    -------------------------------------------------
    -- Negate + banish by bouncing a Kaiju
    -------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.negcon)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

-------------------------------------------------
-- Can activate from hand condition
-------------------------------------------------
function s.handcon(e)
    return Duel.IsExistingMatchingCard(s.kaijufilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) and Duel.IsMainPhase()
end

-------------------------------------------------
-- Filters
-------------------------------------------------
function s.kaijufilter(c)
    return c:IsSetCard(0xd3)
end

-------------------------------------------------
-- Negate condition
-------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==1-tp and Duel.IsChainDisablable(ev)
end

-------------------------------------------------
-- Cost: return 1 Kaiju from anywhere to hand
-------------------------------------------------
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.kaijufilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectMatchingCard(tp,s.kaijufilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SendtoHand(g,nil,REASON_COST)
end

-------------------------------------------------
-- Target
-------------------------------------------------
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if rc:IsRelateToEffect(re) and rc:IsAbleToRemove() then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,tp,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end