--Synchro Warp
local s,id=GetID()

function s.initial_effect(c)

    --Activate from hand
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e0:SetCondition(s.handcon)
    c:RegisterEffect(e0)

    --Contact-style Synchro summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --GY protection
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_NEGATE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.negcon)
    e2:SetCost(aux.bfgcost)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)

end
s.listed_names={44508096,63436931}

--Control Crimson Dragon or Stardust monster
function s.handfilter(c)
    return c:IsCode(63436931) --Crimson Dragon
    or c:IsSetCard(0xa3) -- Stardust archetype (adjust if custom setcode)
end

function s.handcon(e)
    return Duel.IsExistingMatchingCard(
        s.handfilter,
        e:GetHandlerPlayer(),
        LOCATION_MZONE,0,1,nil
    )
end


--Extra deck summonable filter
function s.spfilter(c,e,tp,mg)
    return (c:IsSetCard(0xa3) or c:ListsCode(0x43)) -- Stardust or Junk support
    and c:IsType(TYPE_SYNCHRO)
    and c:IsCanBeSpecialSummoned(
       e,SUMMON_TYPE_SYNCHRO,tp,false,false)
    and mg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),2,99)
end


function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local mg=Duel.GetMatchingGroup(
       Card.IsMonster,tp,
       LOCATION_GRAVE,LOCATION_GRAVE,nil)

    mg=mg:Filter(Card.IsLevelAbove,nil,1)

    if chk==0 then
       return Duel.GetLocationCountFromEx(tp)>0
       and Duel.IsExistingMatchingCard(
         aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),
         tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
       and Duel.IsExistingMatchingCard(
         s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
    end

    Duel.SetOperationInfo(
      0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end


function s.tunercheck(g)
    return g:IsExists(Card.IsType,1,nil,TYPE_TUNER)
end

function s.spop(e,tp)

    local mg=Duel.GetMatchingGroup(
        Card.IsMonster,
        tp,
        LOCATION_GRAVE,LOCATION_GRAVE,
        nil
    ):Filter(Card.IsLevelAbove,nil,1)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

    local ex=Duel.SelectMatchingCard(
        tp,s.spfilter,
        tp,LOCATION_EXTRA,0,
        1,1,nil,e,tp,mg)

    local sc=ex:GetFirst()
    if not sc then return end

    local lv=sc:GetLevel()

    --Must have exact level combination
    if not mg:CheckWithSumEqual(
        Card.GetLevel,lv,2,99) then
        return
    end

    local g
    repeat
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)

        g=mg:SelectWithSumEqual(
            tp,
            Card.GetLevel,
            lv,
            2,99
        )

    until #g==0 or s.tunercheck(g)

    if #g==0 then return end

    Duel.SendtoDeck(
        g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT
    )

    if Duel.SpecialSummon(
        sc,SUMMON_TYPE_SYNCHRO,
        tp,tp,false,false,POS_FACEUP)>0 then
        sc:CompleteProcedure()
    end
end


--GY Negation protection
function s.synfilter(c)
   return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
   if rp==tp then return false end

   return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
      or re:IsHasCategory(CATEGORY_DESTROY)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
   Duel.NegateActivation(ev)
end