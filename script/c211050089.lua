--Devil's Board
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --Activate from hand
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
    --Immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetCondition(s.immcon)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)
    --Restriction
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.splimit)
	c:RegisterEffect(e4)
    --Foolish
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.tgtg)
	e5:SetOperation(s.tgop)
	c:RegisterEffect(e5)
	--------------------------------------------------
	-- End Phase: Banish 1 Spirit Message
	--------------------------------------------------
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1,id+200)
	e6:SetTarget(s.bantg)
	e6:SetOperation(s.banop)
	c:RegisterEffect(e6)
end
s.listed_series={0x1c}
function s.necrofilter(c)
	return c:IsFaceup() and c:IsCode(31829185,14509651,211050076,211050082)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsLocation(LOCATION_HAND) then
		return Duel.IsExistingMatchingCard(s.necrofilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			or Duel.IsExistingMatchingCard(s.necrofilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
	end
	return true
end

function s.immcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.necrofilter,tp,LOCATION_MZONE,0,1,nil)
		or Duel.IsExistingMatchingCard(s.necrofilter,tp,LOCATION_GRAVE,0,1,nil)
end

function s.immval(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end

function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_FIEND)
		and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--------------------------------------------------
-- Face-down banish self
--------------------------------------------------
function s.ctfilter(c)
	return c:IsFaceup()
		and c:IsType(TYPE_CONTINUOUS)
		and c:IsType(TYPE_TRAP)
end

function s.fdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_SZONE,0,1,e:GetHandler())
end

function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEDOWN,REASON_EFFECT)
end

--------------------------------------------------
-- Spirit Message filter
--------------------------------------------------
function s.smfilter(c)
	return c:IsSetCard(0x1c) -- official Spirit Message setcode
		and c:IsAbleToRemove()
end

function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.smfilter,tp,
			LOCATION_HAND+LOCATION_DECK+LOCATION_SZONE+LOCATION_GRAVE,
			0,1,nil)
	end
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.smfilter,tp,
		LOCATION_HAND+LOCATION_DECK+LOCATION_SZONE+LOCATION_GRAVE,
		0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	end

	-- Check win condition
	local rg=Duel.GetMatchingGroup(
		function(c) return c:IsSetCard(0x1c) and c:GetFlagEffect(id)>0 end,
		tp,LOCATION_REMOVED,0,nil)

	if rg:GetClassCount(Card.GetCode)>=4 then
		Duel.Win(tp,WIN_REASON_DESTINY_BOARD)
	end
end