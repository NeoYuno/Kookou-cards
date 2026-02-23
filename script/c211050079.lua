--Forgotten Souls of the Abyss
local s,id=GetID()
function s.initial_effect(c)
    --Banish
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
    --Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetCountLimit(1,id+100)
	c:RegisterEffect(e2)
end
s.listed_names={}
function s.dbfilter(c)
	return c:IsCode(94212438)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsDiscardable()
			and Duel.IsExistingMatchingCard(
				s.dbfilter,tp,
				LOCATION_HAND+LOCATION_DECK+
				LOCATION_SZONE+LOCATION_GRAVE+
				LOCATION_REMOVED,
				0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.dbfilter,tp,
		LOCATION_HAND+LOCATION_DECK+
		LOCATION_SZONE+LOCATION_GRAVE+
		LOCATION_REMOVED,
		0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.rmfilter(c)
	return c:IsMonster() and c:IsAbleToRemove()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp)
		and chkc:IsLocation(LOCATION_GRAVE)
		and s.rmfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_GRAVE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		    local e1=Effect.CreateEffect(e:GetHandler())
		    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		    e1:SetCode(EVENT_CHAIN_SOLVING)
            e1:SetLabel(tc:GetOriginalCodeRule())
		    e1:SetCondition(s.discon)
		    e1:SetOperation(s.disop)
            e1:SetReset(RESET_CHAIN)
		    Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local code1,code2=re:GetHandler():GetOriginalCodeRule()
	return re:IsMonsterEffect() and (code1==code or code2==code)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase()
		and Duel.IsExistingMatchingCard(
			function(c) return c:IsFaceup() and c:IsCode(94212438) end,
			tp,LOCATION_SZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- Send to GY at end of Battle Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE|PHASE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetHintTiming(TIMING_BATTLE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(s.tgop)
		c:RegisterEffect(e1)
	end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end