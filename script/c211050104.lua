--Branded Zone
local s,id=GetID()
function s.initial_effect(c)
    --Activate / Field Spell
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    
    --All monsters on field and opponent's GY become DARK
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(0,LOCATION_MZONE+LOCATION_GRAVE)
    e2:SetTarget(aux.TRUE)
    e2:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e2)
    
    --Main Phase: send 1 LIGHT or DARK Dragon from deck to GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1,id)
    e4:SetTarget(s.tgtg)
    e4:SetOperation(s.tgop)
    c:RegisterEffect(e4)
    
    --End Phase: add 1 Bystial monster from GY or banished if you banished LIGHT/DARK monster this turn
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_PHASE+PHASE_END)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1,id+100)
    e5:SetCondition(s.thcon)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)
    
    --Global effect to track banished monsters
    local ge1=Effect.CreateEffect(c)
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_REMOVE)
    ge1:SetOperation(s.banish_check)
    Duel.RegisterEffect(ge1,0)
end

--Filter for LIGHT/DARK Dragons
function s.tgfilter(c)
    return c:IsRace(RACE_DRAGON) and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) and c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

--End Phase condition: you banished at least 1 LIGHT/DARK monster this turn
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id+200)>0
end

--Filter for Bystial monster
function s.thfilter(c)
    return c:IsSetCard(0x189) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

--Track banished LIGHT/DARK monsters for End Phase
function s.banish_check(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    while tc do
        if tc:IsAttribute(ATTRIBUTE_LIGHT) or tc:IsAttribute(ATTRIBUTE_DARK) and rp==tp then
            Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
        end
        tc=eg:GetNext()
    end
end
