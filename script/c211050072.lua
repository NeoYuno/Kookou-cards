--Exodia, the Unchained Forbidden One
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ATK/DEF gain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- Activate "Obliterate!!!" (Quick Effect)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.obltg)
	e4:SetOperation(s.oblop)
	c:RegisterEffect(e4)
end

s.listed_series={SET_FORBIDDEN_ONE,SET_EXODD}

function s.forbidden_filter(c)
	return c:IsMonster() and c:IsSetCard(SET_FORBIDDEN_ONE) and c:IsAbleToDeckAsCost()
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.forbidden_filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.forbidden_filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(function(tc) return tc:IsSetCard(SET_FORBIDDEN_ONE) and tc:IsMonster() end,c:GetControler(),LOCATION_GRAVE,0,nil)*1000
end

function s.oblfilter(c)
	return c:IsSetCard(SET_EXODD) and c:IsSpellTrap() and c:CheckActivateEffect(false,true,false)~=nil
end

function s.obltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.oblfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) 
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end

function s.oblop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectMatchingCard(tp,s.oblfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local te=tc:GetActivateEffect()
	if not te then return end
    if tc:IsType(TYPE_FIELD) then 
        Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    else
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
	Duel.RaiseEvent(tc,EVENT_CHAINING,e,REASON_EFFECT,tp,tp,0)
	te:UseCountLimit(tp)
	local cost=te:GetCost()
	if cost then cost(te,tp,eg,ep,ev,re,r,rp,1) end
	local tg=te:GetTarget()
	if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
	local op=te:GetOperation()
	if op then op(te,tp,eg,ep,ev,re,r,rp) end
	Duel.RaiseEvent(tc,EVENT_CHAIN_SOLVED,e,REASON_EFFECT,tp,tp,0)
end
