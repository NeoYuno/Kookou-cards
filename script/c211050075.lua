--Shrine of the Forbidden One
local s,id=GetID()
function s.initial_effect(c)
	-- Send 1 "Exodia" or "Forbidden One" monster from Deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- Reveal Spellcaster Normal monsters; draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	-- Opponent cannot banish cards while you control an "Exodia" monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.excon)
	c:RegisterEffect(e3)
	-- Unlimited hand size
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_HAND_LIMIT)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_FZONE)
    e4:SetCondition(s.excon)
	e4:SetTargetRange(1,0)
	e4:SetValue(99)
	c:RegisterEffect(e4)
end

s.listed_series={SET_FORBIDDEN_ONE,SET_EXODIA}

function s.exodiag(c)
	return c:IsFaceup() and c:IsSetCard(SET_EXODIA)
end

function s.excon(e)
	return Duel.IsExistingMatchingCard(s.exodiag,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.tgfilter(c)
	return (c:IsSetCard(SET_FORBIDDEN_ONE) or c:IsSetCard(SET_EXODIA))
		and c:IsMonster() and c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
	    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	    if #g>0 then
		    Duel.SendtoGrave(g,REASON_EFFECT)
	    end
    end
end

function s.revfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_NORMAL) and not c:IsPublic()
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.revfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_HAND,0,1,99,nil)
	if #g==0 then return end
	Duel.ConfirmCards(1-tp,g)
	Duel.Draw(tp,#g,REASON_EFFECT)
	Duel.ShuffleHand(tp)
end
