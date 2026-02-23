--Death's Puppet Master
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,s.mfilter,4,2)
	c:EnableReviveLimit()
    --Send
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
    --Rank up
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.rktg)
	e2:SetOperation(s.rkop)
	c:RegisterEffect(e2)
end
function s.mfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_FIEND,lc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK,lc,sumtype,tp)
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
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

function s.rkfilter(c,e,tp)
	return c:IsRank(8)
		and c:IsRace(RACE_FIEND)
		and c:IsType(TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.necrofilter(c)
	return c:IsMonster() and c:IsCode(31829185,14509651,211050076,211050082)
end
function s.rktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return Duel.IsExistingMatchingCard(s.necrofilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.rkfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
			and c:IsFaceup()
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.rkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	-- Attach Necrofear
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mg=Duel.SelectMatchingCard(tp,s.necrofilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	if #mg==0 then return end
	c:SetMaterial(mg)
	Duel.Overlay(c,mg)
	-- Select Rank 8
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.rkfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local rc=g:GetFirst()
	if not rc then return end
	-- Transfer materials
	local mat=c:GetOverlayGroup()
	if #mat>0 then
		Duel.Overlay(rc,mat)
	end
	rc:SetMaterial(Group.FromCards(c))
	Duel.Overlay(rc,Group.FromCards(c))
	Duel.SpecialSummon(rc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
	rc:CompleteProcedure()
end