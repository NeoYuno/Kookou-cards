--Red-Eyes Pitch Black Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- Quick Effect: Special Summon from hand by banishing Red-Eyes
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- Quick Effect: Immediately Xyz Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.xyztg)
    e2:SetOperation(s.xyzop)
    c:RegisterEffect(e2)
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_series={0x3b}
function s.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA or (c:IsType(TYPE_FUSION) or c:IsType(TYPE_XYZ))
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3b)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsMainPhase() then return false end
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
        or Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetReset(RESET_PHASE|PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end

function s.cfilter(c)
    return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
    Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

function s.xyzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetReset(RESET_PHASE|PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end

function s.xyzfilter(c)
    return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER)
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,e:GetHandler())
            and Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(0x3b) and c:IsType(TYPE_XYZ) end,tp,LOCATION_EXTRA,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,c)
    local tc=g:GetFirst()
    if not tc or not c:IsRelateToEffect(e) then return end
    -- Apply temporary overrides
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_LEVEL)
    e1:SetValue(7)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CHANGE_RACE)
    e2:SetValue(RACE_DRAGON)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e3:SetValue(ATTRIBUTE_DARK)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e3)
    -- Now validate summon
    local matg=Group.FromCards(c,tc)
    local xyzg=Duel.GetMatchingGroup(function(xc)
        return xc:IsSetCard(0x3b) and xc:IsType(TYPE_XYZ) and xc:IsXyzSummonable(nil,matg)
    end,tp,LOCATION_EXTRA,0,nil)
    if #xyzg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
        Duel.XyzSummon(tp,xyz,nil,matg)
    end
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsType(TYPE_FUSION) or c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not (c:IsOriginalType(TYPE_SYNCHRO) and c:IsOriginalAttribute(ATTRIBUTE_DARK))
end