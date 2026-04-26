--Shining Starlight
local s,id=GetID()

function s.initial_effect(c)

    --Activate from hand
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e0:SetCondition(s.handcon)
    c:RegisterEffect(e0)

    --Main summon effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --GY dodge effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.rmcon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)

end


--Activate from hand
function s.handcon(e)
   local tp=e:GetHandlerPlayer()
   return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
   and Duel.IsExistingMatchingCard(
      Card.IsSummonType,tp,0,LOCATION_MZONE,
      1,nil,SUMMON_TYPE_SPECIAL)
end


--Synchron monsters in Deck
function s.syncfilter(c)
   return c:IsSetCard(0x1017)
      and c:IsAbleToRemoveAsCost()
      and c:IsLevelAbove(1)
end


--Stardust or Junk Synchros
function s.exfilter(c,e,tp,mg)
   return c:IsType(TYPE_SYNCHRO)
   and c:IsLevelBelow(8)
   and (
      c:IsSetCard(0xa3) -- Stardust
      or c:IsSetCard(0x43) -- Junk
   )
   and c:IsCanBeSpecialSummoned(
      e,SUMMON_TYPE_SYNCHRO,tp,false,false)
   and mg:CheckWithSumEqual(
      Card.GetLevel,c:GetLevel(),1,99)
end


function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
   local mg=Duel.GetMatchingGroup(
      s.syncfilter,tp,LOCATION_DECK,0,nil)

   if chk==0 then
      return Duel.GetLocationCountFromEx(tp)>0
      and Duel.IsExistingMatchingCard(
         s.exfilter,tp,LOCATION_EXTRA,0,
         1,nil,e,tp,mg)
   end

   Duel.SetOperationInfo(
      0,CATEGORY_SPECIAL_SUMMON,
      nil,1,tp,LOCATION_EXTRA)
end


function s.spop(e,tp)

    local mg=Duel.GetMatchingGroup(
        s.syncfilter,tp,LOCATION_DECK,0,nil)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

    local ex=Duel.SelectMatchingCard(
        tp,s.exfilter,tp,
        LOCATION_EXTRA,0,1,1,nil,e,tp,mg)

    local sc=ex:GetFirst()
    if not sc then return end

    local lv=sc:GetLevel()

    --Check valid level combination exists
    if not mg:CheckWithSumEqual(Card.GetLevel,lv,1,99) then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)

    local g=mg:SelectWithSumEqual(
        tp,
        Card.GetLevel,
        lv,
        1,99
    )

    if #g==0 then return end

    --Effect banishes them first during resolution
    Duel.Remove(g,POS_FACEUP,REASON_EFFECT)

    --Then summon
    if Duel.SpecialSummon(
        sc,SUMMON_TYPE_SYNCHRO,
        tp,tp,false,false,POS_FACEUP)>0 then
        sc:CompleteProcedure()
    end
end


--GY effect requires Stardust Dragon
function s.rmcon(e,tp)
   return Duel.IsExistingMatchingCard(
      Card.IsCode,tp,LOCATION_MZONE,0,
      1,nil,44508094)
end

function s.rmfilter(c)
   return c:IsOnField()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then
      return Duel.IsExistingTarget(
         Card.IsCode,tp,
         LOCATION_MZONE,0,1,nil,44508094)
      and Duel.IsExistingTarget(
         s.rmfilter,tp,
         LOCATION_MZONE,LOCATION_MZONE,
         2,nil)
   end

   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)

   local g1=Duel.SelectTarget(
      tp,Card.IsCode,tp,
      LOCATION_MZONE,0,
      1,1,nil,44508094)

   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)

   local g2=Duel.SelectTarget(
      tp,s.rmfilter,tp,
      LOCATION_MZONE,LOCATION_MZONE,
      1,1,g1:GetFirst())

   g1:Merge(g2)
end


function s.rmop(e,tp)
   local g=Duel.GetTargetCards(e)
   if #g~=2 then return end

   local rg=g:Filter(Card.IsRelateToEffect,nil,e)

   if #rg>0 then
      Duel.Remove(rg,POS_FACEUP,
         REASON_EFFECT+REASON_TEMPORARY)

      local tc=rg:GetFirst()
      while tc do
         local e1=Effect.CreateEffect(e:GetHandler())
         e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
         e1:SetCode(EVENT_PHASE+PHASE_END)
         e1:SetLabelObject(tc)
         e1:SetCountLimit(1)
         e1:SetOperation(function(e,tp)
            local c=e:GetLabelObject()
            if c and c:IsLocation(LOCATION_REMOVED) then
               Duel.ReturnToField(c)
            end
            e:Reset()
         end)
         e1:SetReset(RESET_PHASE+PHASE_END)
         Duel.RegisterEffect(e1,tp)
         tc=rg:GetNext()
      end
   end
end