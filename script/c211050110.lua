--Meteor Stardust Dragon
local s,id=GetID()

function s.initial_effect(c)

    --Synchro Summon
    Synchro.AddProcedure(c,nil,1,1,s.matfilter,1,99)
    c:EnableReviveLimit()

    --Treated as non-tuner
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_NONTUNER)
	e0:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e0)

    --Name becomes Stardust Dragon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ADD_CODE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e2:SetValue(44508094) -- Stardust Dragon
    c:RegisterEffect(e2)

    --Cannot be targeted
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)

    --Cannot be destroyed by effects
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetValue(1)
    c:RegisterEffect(e4)

    --Quick spin effect
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_TODECK)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id)
    e5:SetCost(s.tdcost)
    e5:SetTarget(s.tdtg)
    e5:SetOperation(s.tdop)
    c:RegisterEffect(e5)

    --Float into Stardust Dragon
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,1))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_LEAVE_FIELD)
    e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetCountLimit(1,{id,1})
    e6:SetCondition(s.spcon)
    e6:SetTarget(s.sptg)
    e6:SetOperation(s.spop)
    c:RegisterEffect(e6)

end


--Non-Tuner Synchro Dragon or Warrior material
function s.matfilter(c,sc,sumtype,tp)
    return c:IsType(TYPE_SYNCHRO,sc,sumtype,tp)
    and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_WARRIOR))
end


--Cost: shuffle Level 8+ Synchro from field/GY into Deck
function s.cfilter(c)
    return c:IsLevelAbove(8)
    and c:IsType(TYPE_SYNCHRO)
    and c:IsAbleToDeckAsCost()
end

function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.cfilter,tp,
            LOCATION_MZONE+LOCATION_GRAVE,
            0,1,nil
        )
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(
        tp,s.cfilter,tp,
        LOCATION_MZONE+LOCATION_GRAVE,
        0,1,1,nil
    )
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end


function s.tdfilter(c)
    return c:IsAbleToDeck()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	end
	Duel.SetChainLimit(aux.FALSE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end


--Float if leaves field
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end

function s.spfilter(c,e,tp)
    return c:IsCode(44508094)
    and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCountFromEx(tp)>0
        and Duel.IsExistingMatchingCard(
            s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp
        )
    end

    Duel.SetOperationInfo(
        0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA
    )
end

function s.spop(e,tp)
    if Duel.GetLocationCountFromEx(tp)<=0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

    local g=Duel.SelectMatchingCard(
        tp,s.spfilter,tp,
        LOCATION_EXTRA,0,1,1,nil,e,tp
    )

    local tc=g:GetFirst()
    if tc then
        Duel.SpecialSummon(
            tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP
        )
        tc:CompleteProcedure()
    end
end