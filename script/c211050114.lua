--Red-Eyes Skull Fiend
local s,id=GetID()

function s.initial_effect(c)

    --Quick Special Summon from hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --Destroy when Special Summoned
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    --Quick Fusion Summon using GY
    local e3=Effect.CreateEffect(c)
    local params = {fusfilter=s.fmfilter,matfilter=aux.FALSE,extrafil=s.fextra,extraop=Fusion.BanishMaterial,gc=Fusion.ForcedHandler,extratg=s.extratarget}
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(Fusion.SummonEffTG(params))
	e3:SetOperation(Fusion.SummonEffOP(params))
    c:RegisterEffect(e3)

end


--Red-Eyes monster exists on field or GY
function s.redfilter(c)
    return c:IsSetCard(0x3b)
end

function s.spcon(e,tp)
    return Duel.IsExistingMatchingCard(
        s.redfilter,tp,
        LOCATION_MZONE+LOCATION_GRAVE,
        0,1,nil
    )
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(
            e,0,tp,false,false)
    end

    Duel.SetOperationInfo(
        0,CATEGORY_SPECIAL_SUMMON,
        e:GetHandler(),1,0,0)
end

function s.spop(e,tp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(
            c,0,tp,tp,false,false,POS_FACEUP)
    end
end


--Destroy on summon
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
       return chkc:IsOnField() and chkc:IsControler(1-tp)
    end
    if chk==0 then
        return Duel.IsExistingTarget(
            Card.IsDestructable,
            tp,0,LOCATION_ONFIELD,1,nil)
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)

    local g=Duel.SelectTarget(
        tp,Card.IsDestructable,
        tp,0,LOCATION_ONFIELD,
        1,1,nil)

    Duel.SetOperationInfo(
       0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end


--Fusion monster filter
function s.fmfilter(c,e,tp,m,f,gc,chkf)
	return c:IsSetCard(0x3b)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),0,tp,LOCATION_MZONE+LOCATION_GRAVE)
end