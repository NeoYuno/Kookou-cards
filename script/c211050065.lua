-- Slattern the Mega Kaiju
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
    -- Fusion Material
    Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)
    -- Alt Summon: Reveal Kaiju in hand + Tribute opp Kaiju
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.altcon)
    e1:SetOperation(s.altop)
    c:RegisterEffect(e1)
    -- Search 1 Kaiju Spell/Trap on Fusion Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
s.listed_series={0xd3}
function s.matfilter1(c)
    return c:IsSetCard(0xd3) and c:IsLocation(LOCATION_MZONE)
end
function s.matfilter2(c)
    return c:IsSetCard(0xd3)
end

function s.altfilter_hand(c)
    return c:IsSetCard(0xd3) and not c:IsPublic()
end
function s.altfilter_opp(c,tp)
    return c:IsFaceup() and c:IsSetCard(0xd3) and c:IsReleasable()
end
function s.altcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.altfilter_hand,tp,LOCATION_HAND,0,1,nil)
        and Duel.IsExistingMatchingCard(s.altfilter_opp,tp,0,LOCATION_MZONE,1,nil)
end
function s.altop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local hg=Duel.SelectMatchingCard(tp,s.altfilter_hand,tp,LOCATION_HAND,0,1,1,nil)
    Duel.ConfirmCards(1-tp,hg)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local sg=Duel.SelectMatchingCard(tp,s.altfilter_opp,tp,0,LOCATION_MZONE,1,1,nil,tp)
    Duel.Release(sg,REASON_COST+REASON_FUSION+REASON_MATERIAL)
    c:SetMaterial(sg)
    c:CompleteProcedure()
end

function s.thfilter(c)
    return c:IsSetCard(0xd3) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
