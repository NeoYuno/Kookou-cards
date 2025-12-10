-- Bahamut, the God of All Kaijus
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
    Fusion.AddProcMix(c,true,true,s.matfilter,s.matfilter)
    -- Alt Summon: Tribute 2 Kaiju monsters on the field (Fusion Summon)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.altcon)
    e1:SetOperation(s.altop)
    c:RegisterEffect(e1)
    -- On Fusion Summon: Add 3 Kaiju counters to any card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_COUNTER)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.cttg)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)
    -- Quick Effect: remove 2 counters → tribute opponent monster → summon Kaiju to their field
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e3:SetCountLimit(1,{id,2})
    e3:SetCost(s.kjcost)
    e3:SetTarget(s.kjtg)
    e3:SetOperation(s.kjop)
    c:RegisterEffect(e3)
end
s.listed_series={0xd3}
s.counter_list={COUNTER_KAIJU}
function s.matfilter(c)
    return c:IsSetCard(0xd3)
end

function s.altfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xd3) and c:IsReleasable()
end
function s.altcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.altfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil)
end
function s.altop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,s.altfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
    Duel.Release(g,REASON_COST)
    c:SetMaterial(g)
end

function s.ctfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xd3) or c:IsCode(56111151)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local tc=Duel.SelectMatchingCard(tp,s.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
    if tc then tc:AddCounter(COUNTER_KAIJU,3) end
end

function s.kjcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,COUNTER_KAIJU,2,REASON_COST) end
    Duel.RemoveCounter(tp,1,1,COUNTER_KAIJU,2,REASON_COST)
end

function s.kjfilter(c)
    return c:IsReleasable()
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0xd3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.kjtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.kjfilter,tp,0,LOCATION_MZONE,1,nil)
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.kjop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local rg=Duel.SelectMatchingCard(tp,s.kjfilter,tp,0,LOCATION_MZONE,1,1,nil)
    if #rg==0 or Duel.Release(rg,REASON_EFFECT)==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,1-tp,false,false,POS_FACEUP)
    end
end
