--Evil's Sanctuary
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.statfilter)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
    --Recover
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	e4:SetCountLimit(1,id)
	c:RegisterEffect(e4)
    --Change effect
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp and re:IsMonsterEffect() and re:GetActivateLocation()==LOCATION_MZONE end)
	e5:SetCost(s.chngcost)
	e5:SetTarget(s.chngtg)
	e5:SetOperation(s.chngop)
	c:RegisterEffect(e5)
    --Draw
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCountLimit(1,{id,2})
	e6:SetCondition(s.drcon)
	e6:SetTarget(s.drtg)
	e6:SetOperation(s.drop)
	c:RegisterEffect(e6)
end
function s.statfilter(e,c)
	return c:IsRace(RACE_FIEND)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_FIEND)
		and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.necrogy(c)
	return c:IsMonster() and c:IsCode(31829185,14509651,211050076,211050082)
end
function s.chngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			function(c) return c:IsAttribute(ATTRIBUTE_DARK)
				and c:IsRace(RACE_FIEND)
				and c:IsDiscardable() end,
			tp,LOCATION_HAND,0,1,nil)
	end
	Duel.DiscardHand(tp,
		function(c) return c:IsAttribute(ATTRIBUTE_DARK)
			and c:IsRace(RACE_FIEND) end,
		1,1,REASON_COST+REASON_DISCARD)
end
function s.chngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(s.necrogy,tp,LOCATION_GRAVE,0,1,nil) 
    end
end
function s.chngop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.GetControl(e:GetHandler(),1-tp,PHASE_END,1)
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end

function s.drfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_FIEND)
		and c:IsAbleToDeck()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1)
			and Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_GRAVE,0,2,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsAbleToDeck() then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.drfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	if #g<2 then return end
	g:AddCard(c)

	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if Duel.Draw(tp,1,REASON_EFFECT)>0 then end
end