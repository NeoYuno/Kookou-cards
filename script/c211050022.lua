--Chaos Soldier of the Beginning
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local f0=Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,1)
	f0:SetDescription(aux.Stringid(id,4))
	local f1=Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_DARK),1,1)
	f1:SetDescription(aux.Stringid(id,5))
    --This card is also LIGHT
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(LOCATION_ALL)
	e1:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e1)
    --Banish 1 LIGHT + 1 DARK from GY to send 1 card on field to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.tgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--Add 1 banished LIGHT or DARK to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.thcon)
    e3:SetCost(s.cost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
    --Special Summon from GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.ctfilter)
end

function s.synfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
end
function s.ctfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or s.synfilter(c)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--Cannot Special Summon monsters from the Extra Deck, except LIGHT or DARK Synchro monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not s.synfilter(c) end)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,s.lizfilter)
end

function s.attfilter(c)
    return c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_LIGHT)
end

function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
		and aux.SpElimFilter(c,true,false) and c:IsAbleToRemoveAsCost()
end
function s.attrfilter(c,sg)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and sg:FilterCount(Card.IsAttribute,c,ATTRIBUTE_DARK)==1
end
function s.sprescon(sg,e,tp,mg)
	return sg:IsExists(s.attrfilter,1,nil,sg)
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 and aux.SelectUnselectGroup(g,e,tp,2,2,s.sprescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.sprescon,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
    --Cannot Special Summon monsters from the Extra Deck, except LIGHT or DARK Synchro monsters
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,3))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE|PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not s.synfilter(c) end)
    Duel.RegisterEffect(e1,tp)
    --Clock Lizard check
    aux.addTempLizardCheck(c,tp,s.lizfilter)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

function s.thfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsAbleToHand()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_REMOVED,0,1,nil,ATTRIBUTE_LIGHT)
		and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_REMOVED,0,1,nil,ATTRIBUTE_DARK)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.ssfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
function s.ssfilter1(c,sg)
	return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and sg:IsExists(s.ssfilter2,1,c,(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)&~c:GetAttribute())
end
function s.ssfilter2(c,att)
	if att == 0 then att = ATTRIBUTE_LIGHT|ATTRIBUTE_DARK end
	return c:IsAttribute(att)
end
function s.ssrescon(sg,e,tp,mg)
	return sg:IsExists(s.ssfilter1,1,nil,sg) and aux.ChkfMMZ(1)(sg,e,tp,mg)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.ssfilter,tp,LOCATION_GRAVE,0,c)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 and aux.SelectUnselectGroup(g,e,tp,2,2,s.ssrescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.ssrescon,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	--Cannot Special Summon monsters from the Extra Deck, except LIGHT or DARK Synchro monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not s.synfilter(c) end)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,s.lizfilter)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end