--Red-Eyes One Thousand Dragon
local s,id=GetID()
function s.initial_effect(c)
	-- Proper Fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,
		s.matfilter_redeyes_small,                              -- 1 Level 4 or lower "Red-Eyes"
		aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT))        -- + 1 Effect monster

	-- "Only Special Summon once per turn" (this card name)
	c:SetSPSummonOnce(id)

	-- Alt Special Summon by sending a monster that's equipped with a monster that mentions "Red-Eyes"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.altspcon)
	e0:SetOperation(s.altsPOP)
	c:RegisterEffect(e0)

	-- On Special Summon: add 1 "Red-Eyes Lair" from Deck/GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- From GY: Equip to a "Red-Eyes" and grant name-change; banish this card when it leaves field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end

-- constants / listings
s.listed_series={0x3b}               -- "Red-Eyes"
s.listed_names={74677422}            -- "Red-Eyes Black Dragon"

-- ===== Fusion material filters =====
function s.matfilter_redeyes_small(c,fc,sumtype,tp)
	return c:IsSetCard(0x3b,fc,sumtype,tp) and c:IsLevelBelow(4)
end

-- ===== Alt Special Summon (from Extra by sending a monster that's equipped with a monster that *mentions* "Red-Eyes") =====
function s.eqfilter(c)
    return (c:ListsCodeWithArchetype(0x3b) or c:ListsArchetype(0x3b)) and c:IsOriginalType(TYPE_MONSTER)
end
function s.altspfilter(c,tp)
	-- Face-up monster you control that is currently equipped with at least one monster that mentions "Red-Eyes"
	return c:IsFaceup() and c:IsControler(tp) and c:GetEquipGroup():IsExists(s.eqfilter,1,nil)
end
function s.altspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and Duel.IsExistingMatchingCard(s.altspfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function s.altsPOP(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.altspfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	if #g>0 then
		-- send only the selected monster to GY (its equips will naturally fall off)
		Duel.SendtoGrave(g,REASON_COST)
	end
end

-- ===== On Special Summon: search/add "Red-Eyes Lair" from Deck or GY =====
function s.thfilter(c)
	return c:IsCode(211050011) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- ===== GY Ignition: Equip self to a "Red-Eyes" you control, banish when leaves, and change equipped monster's original name =====
-- ===== GY Ignition: Equip self to a "Red-Eyes" you control, banish when leaves, and change equipped monster's original name =====
function s.redctlfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3b)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.redctlfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.redctlfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	Duel.Equip(tp,c,tc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(true)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- Equipped monster gains: Original name becomes "Red-Eyes Black Dragon"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetValue(74677422) -- Red-Eyes Black Dragon
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
