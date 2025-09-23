--Archfiend Destroyer
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    local ritual_params={handler=c,lvtype=RITPROC_GREATER,filter=function(ritual_c) return ritual_c:IsRace(RACE_FIEND) and ritual_c~=c end,location=LOCATION_GRAVE,forcedselection=function(e,tp,g,sc) return g:IsContains(e:GetHandler()) end}
	--Ritual Summon 1 Ritual Monster from your GY, by Tributing monsters from your hand or field, including this card on your field, whose total Levels equal or exceed the Level of the Ritual Monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
    e1:SetCost(Cost.AND(Cost.SelfReveal,s.cost))
	e1:SetTarget(Ritual.Target(ritual_params))
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				if c:IsRelateToEffect(e) and c:IsControler(tp) then
					Ritual.Operation(ritual_params)(e,tp,eg,ep,ev,re,r,rp)
				end
			end)
	c:RegisterEffect(e1)
    --Foolish
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.cost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
    --Destroy
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCost(s.gycost)
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_FIEND) end)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--Cannot Special Summon from the Extra Deck, except Fiend Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_FIEND) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.tgfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

function s.cfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToRemoveAsCost()
end
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return e:GetHandler():IsAbleToRemoveAsCost()
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler())
            and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	--store highest ATK among removed
	local atk=0
	for tc in aux.Next(g) do
		if tc:GetAttack()>atk then atk=tc:GetAttack() end
	end
	e:SetLabel(atk)
    --Cannot Special Summon from the Extra Deck, except Fiend Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_FIEND) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    local atk=e:GetLabel()
	if chk==0 then
        local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
        local dg=g:Filter(function(c) return c:IsFaceup() and c:GetAttack()<atk end,nil)
        return #dg>0
    end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetLabel()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	local dg=g:Filter(function(c) return c:IsFaceup() and c:GetAttack()<atk end,nil)
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
