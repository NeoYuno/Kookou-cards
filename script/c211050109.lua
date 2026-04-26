--Mecha Stardust Dragon
local s,id=GetID()

function s.initial_effect(c)

    --Synchro Procedure
    Synchro.AddProcedure(c,nil,1,1,s.matfilter,1,1)
    c:EnableReviveLimit()

    --Treat as non-Tuner on field
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_NONTUNER)
	e0:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e0)

    --Special Summon Level 1 Dragon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.spcon)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --Quick Synchro Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.synctg)
    e2:SetOperation(s.syncop)
    c:RegisterEffect(e2)

end


--Non-Tuner material must be WIND Dragon Synchro
function s.matfilter(c,scard,sumtype,tp)
    return c:IsRace(RACE_DRAGON)
        and c:IsAttribute(ATTRIBUTE_WIND)
        and c:IsType(TYPE_SYNCHRO,scard,sumtype,tp)
end


--Triggered only if Synchro Summoned
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end


function s.lv1filter(c,e,tp)
    return c:IsLevel(1)
        and c:IsRace(RACE_DRAGON)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(
            s.lv1filter,
            tp,
            LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,
            0,1,nil,e,tp
        )
    end

    Duel.SetOperationInfo(
        0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE
    )
end

function s.spop(e,tp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

    local g=Duel.SelectMatchingCard(
        tp,s.lv1filter,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,
        0,1,1,nil,e,tp
    )

    if #g>0 then
        Duel.SpecialSummon(
            g,0,tp,tp,false,false,POS_FACEUP
        )
    end
end


--Quick Synchro Climb
function s.synctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.syncop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end