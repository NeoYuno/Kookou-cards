--Debris Stardust Synchron
local s,id=GetID()

function s.initial_effect(c)

    --Treat as non-Tuner
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_NONTUNER)
	e0:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e0)

    --Special Summon from GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
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

    --Negate effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)

end


--Control Stardust Dragon, Junk Warrior, or Synchron
function s.spfilter(c)
    return c:IsCode(44508094,60800381)
        or c:IsSetCard(0x1017)
end

function s.spcon(e,tp)
    return Duel.IsExistingMatchingCard(
        s.spfilter,tp,LOCATION_MZONE,0,1,nil
    )
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(
        0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0
    )
end

function s.spop(e,tp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e)
    and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then

        --Banish when leaves field
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1,true)
    end
end


--Quick Synchro
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

--Opponent activates effect that negates effects/activations
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local ex,tg,ct=Duel.GetOperationInfo(ev,CATEGORY_NEGATE) or Duel.GetOperationInfo(ev,CATEGORY_DISABLE)
	if not ex then return false end
    local ce=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
	if ce:IsActiveType(TYPE_MONSTER) and (ce:GetHandler():IsType(TYPE_TUNER) or ce:GetHandler():IsType(TYPE_SYNCHRO)) then
        return true
    end
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return e:GetHandler():IsAbleToGraveAsCost()
    end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev)
    and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(re:GetHandler(),REASON_EFFECT)
    end
end