--Crimson Stardust Dragon
local s,id=GetID()

function s.initial_effect(c)

    --Only control 1
    c:SetUniqueOnField(1,0,id)

    --Synchro Summon
    Synchro.AddProcedure(c,nil,1,1,s.matfilter,1,99)
    c:EnableReviveLimit()

    --Reactive negate / tag out
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

end


--Non-Tuner materials:
--WIND Dragon or Machine
function s.matfilter(c,scard,sumtype,tp)
    return c:IsAttribute(ATTRIBUTE_WIND)
        and (c:IsRace(RACE_DRAGON)
        or c:IsRace(RACE_MACHINE))
end


--Approximation:
--respond to effects likely affecting cards on field
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
        or re:IsHasCategory(CATEGORY_DESTROY)
        or re:IsHasCategory(CATEGORY_REMOVE)
        or re:IsHasCategory(CATEGORY_NEGATE)
        or re:IsHasCategory(CATEGORY_DISABLE)
end


function s.spfilter(c,e,tp)
    return c:IsType(TYPE_SYNCHRO)
        and c:IsRace(RACE_DRAGON)
        and c:IsLevelBelow(10)
        and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(
            e,SUMMON_TYPE_SYNCHRO,tp,false,false
        )
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(
            s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp
        )
    end

    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(
        0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA
    )
end


function s.negop(e,tp,eg,ep,ev,re,r,rp)

    local c=e:GetHandler()

    if not Duel.NegateActivation(ev) then return end

    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

    local g=Duel.SelectMatchingCard(
        tp,s.spfilter,tp,
        LOCATION_EXTRA,0,1,1,nil,e,tp
    )

    local sc=g:GetFirst()
    if not sc then return end

    --Return this card to Extra Deck
    if Duel.SendtoDeck(
        c,nil,SEQ_DECKTOP,REASON_EFFECT
    )~=0 then

        --Summon replacement as Synchro Summon
        Duel.SpecialSummon(
            sc,SUMMON_TYPE_SYNCHRO,
            tp,tp,false,false,POS_FACEUP
        )
        sc:CompleteProcedure()
    end

end