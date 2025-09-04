--Red-Eyes Darkness Twin Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),7,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzcheck)
	c:EnableReviveLimit()
	--Cannot be targeted while it has material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():GetOverlayCount()>0 end)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--Treat Red-Eyes Normal Spells as Quick-Play (only during Main Phase)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(function(e,c) return c:IsSetCard(0x3b) and c:IsSpell() and not c:IsType(TYPE_QUICKPLAY) end)
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	c:RegisterEffect(e2)
	--Allow activation of Red-Eyes Quick-Play Spells from hand (only during Main Phase)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetTarget(function(e,c) return c:IsSetCard(0x3b) and c:IsSpell() end)
	e3:SetCondition(function() return Duel.IsMainPhase() end)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_HAND,0)
	e4:SetTarget(function(e,c) return c:IsSetCard(0x3b) and c:IsTrap() end)
	e4:SetCondition(function() return Duel.IsMainPhase() end)
	c:RegisterEffect(e4)
	--Detach 1 to search Red-Eyes Spell/Trap
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	end)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
--Extra checks for Xyz summon
function s.ovfilter(c,tp,lc)
	return false
end
function s.xyzcheck(g,tp,lc)
	return g:GetClassCount(Card.GetAttribute)==1 and g:GetFirst():IsAttribute(ATTRIBUTE_DARK)
end
--Search Red-Eyes Spell/Trap
function s.thfilter(c)
	return c:IsSetCard(0x3b) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
