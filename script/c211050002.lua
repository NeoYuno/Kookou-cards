--Red-Eyes JoeyMan
local s,id=GetID()
function s.initial_effect(c)
	-- (e1) On Summon: reveal 3 REBD, then SS 1 REBD; if SS succeeds, Level becomes 7 and treated as Dragon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	local e1c=e1:Clone()
	e1c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1c)

	-- (e2) If used as Fusion Material: add 1 Level 7 "Red-Eyes" from Deck to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon_fusion)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	-- (e3) If detached from a DARK Dragon Xyz as cost: add 1 Level 7 "Red-Eyes" from Deck to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.thcon_detach)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

-- constants
local REBD=74677422 -- "Red-Eyes B. Dragon"
local SET_REDEYES=0x3b

s.listed_names={REBD}
s.listed_series={SET_REDEYES}

-- ===== e1: Summon -> reveal 3 REBD, then SS 1 REBD =====
-- can be revealed from: hand, Deck, your field (face-up only), GY, banished
function s.revealfilter(c)
	-- allow: hand/deck/gy/banished; and face-up on field
	if c:IsCode(REBD) then
		if c:IsLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED) then return true end
		if c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then return true end
	end
	return false
end
function s.spfilter(c,e,tp)
	return c:IsCode(REBD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc_reveal=LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_MZONE
	local loc_ss=LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.revealfilter,tp,loc_reveal,0,3,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,loc_ss,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc_ss)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc_reveal=LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_MZONE
	local loc_ss=LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED
	-- reveal exactly 3 REBD
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rg=Duel.SelectMatchingCard(tp,s.revealfilter,tp,loc_reveal,0,3,3,nil)
	if #rg<3 then return end
	Duel.ConfirmCards(1-tp,rg)
	-- shuffle zones we peeked (hand/deck)
	Duel.ShuffleHand(tp)
	Duel.ShuffleDeck(tp)
	-- SS 1 REBD from hand/Deck/GY/banished
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,loc_ss,0,1,1,nil,e,tp)
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- Level becomes 7
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(7)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- Treated as Dragon (add Dragon Race)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_RACE)
		e2:SetValue(RACE_DRAGON)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end

-- ===== e2: If used as Fusion Material =====
function s.thcon_fusion(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_FUSION)~=0
end

-- ===== e3: If detached from a DARK Dragon Xyz as cost =====
function s.thcon_detach(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- must have been in overlay, sent as COST by an Xyz monster's effect, and that monster is DARK Dragon
	return c:IsPreviousLocation(LOCATION_OVERLAY)
		and c:IsReason(REASON_COST)
		and re and re:IsActiveType(TYPE_XYZ)
		and re:GetHandler():IsAttribute(ATTRIBUTE_DARK) and re:GetHandler():IsRace(RACE_DRAGON)
end

-- common search for Level 7 "Red-Eyes"
function s.thfilter(c)
	return c:IsSetCard(SET_REDEYES) and c:IsLevel(7) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
