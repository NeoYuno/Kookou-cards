-- Kaiju Opening Trench
local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(COUNTER_KAIJU)
    c:EnableCounterPermit(COUNTER_KAIJU)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    --Protection: cards you control with Kaiju Counter
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_ONFIELD,0)
    e1:SetCondition(s.protcon)
    e1:SetTarget(s.prottg)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    --Place 3 Kaiju Counters on this card
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_COUNTER)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.cttg)
    e3:SetOperation(s.ctop)
    c:RegisterEffect(e3)
    --Remove 1 Kaiju Counter → SS Kaiju from GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1,{id,2})
    e4:SetCost(s.spcost)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end
s.listed_series={0xd3}
s.counter_list={COUNTER_KAIJU}
function s.protcon(e)
    return Duel.IsExistingMatchingCard(function(tc) return tc:GetCounter(COUNTER_KAIJU)>0 end,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.prottg(e,c)
    return c:IsFaceup() and c:IsSetCard(0xd3)
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanAddCounter(COUNTER_KAIJU,3) end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():AddCounter(COUNTER_KAIJU,3)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,COUNTER_KAIJU,1,REASON_COST) end
    Duel.RemoveCounter(tp,1,1,COUNTER_KAIJU,1,REASON_COST)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0xd3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
