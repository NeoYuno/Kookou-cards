--Branded Final Battle
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --Banish from GY to send banished cards to GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
end

--Activate: Send top 5 of each deck to GY, then special summon "Bystial" monster
function s.tgfilter(c,e,tp)
    return c:IsSetCard(0x189) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,10,PLAYER_ALL,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetDecktopGroup(tp,5)
    local g2=Duel.GetDecktopGroup(1-tp,5)
    g1:Merge(g2)
    Duel.SendtoGrave(g1,REASON_EFFECT)
    
    -- Special Summon a Bystial monster from GY
    local sg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
    if #sg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=sg:Select(tp,1,1,nil):GetFirst()
        Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
    end
    
    -- Prevent monster effects in GY except Dragons
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_TRIGGER)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e1:SetTargetRange(LOCATION_GRAVE,0)
    e1:SetTarget(s.rmlimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.rmlimit(e,c)
    return c:IsMonster() and not c:IsRace(RACE_DRAGON)
end

function s.tgfilter2(c)
    return c:IsFaceup() and c:GetCode()~=id and c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_REMOVED,0,1,nil) 
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectTarget(tp,s.tgfilter2,tp,LOCATION_REMOVED,0,1,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e)
    if tg and #tg>0 then
        Duel.SendtoGrave(tg,REASON_EFFECT+REASON_RETURN)
    end
end