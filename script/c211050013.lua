--Red-Eyes Ultimate Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
    local e1=Fusion.CreateSummonEff({handler=c,fusfilter=s.filter,matfilter=aux.FALSE,extrafil=s.fextra,extraop=Fusion.ShuffleMaterial,stage2=s.stage2,extratg=s.extratg})
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={0x3b}
s.listed_names={CARD_REDEYES_B_DRAGON}
function s.filter(c)
    return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.fextrafil(c)
	return c:IsAbleToDeck() and (c:IsLocation(LOCATION_HAND) or c:IsOnField() or c:IsFaceup())
end
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsCode,1,nil,CARD_REDEYES_B_DRAGON)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(s.fextrafil),tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED,0,nil),s.fcheck
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(CARD_REDEYES_B_DRAGON)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED)
end
