--Stardust Junk Dragon
local s,id=GetID()

function s.initial_effect(c)

    --Synchro Summon
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()

    --Also treated as non-Tuner
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_NONTUNER)
    e0:SetValue(1)
    c:RegisterEffect(e0)

    --Name becomes Stardust Dragon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(44508094)
    c:RegisterEffect(e1)

    --Special Summon from Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.spcon)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    --Quick Synchro during opponent's turn
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.synccon)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.synctg)
    e3:SetOperation(s.syncop)
    c:RegisterEffect(e3)

end


--Synchro summon only
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end


--Mentions Junk Warrior or Stardust Dragon
function s.spfilter(c,e,tp)
    return (c:ListsCode(60800381) or c:ListsCode(44508094))
    and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
       return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
       and Duel.IsExistingMatchingCard(
            s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    end

    Duel.SetOperationInfo(
        0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end


function s.spop(e,tp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

    local g=Duel.SelectMatchingCard(
        tp,s.spfilter,tp,
        LOCATION_DECK,0,1,1,nil,e,tp)

    if #g>0 then
        Duel.SpecialSummon(
            g,0,tp,tp,false,false,POS_FACEUP)

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c)
        return c:IsLocation(LOCATION_EXTRA)
        and not c:IsType(TYPE_SYNCHRO)
    end)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)
    end
end


--Opponent's turn only
function s.synccon(e,tp)
    return Duel.GetTurnPlayer()~=tp
end

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
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c)
        return c:IsLocation(LOCATION_EXTRA)
        and not c:IsType(TYPE_SYNCHRO)
    end)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)
end