trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, after delete, after undelete) {

    if(Trigger.isInsert){
        if(Trigger.isBefore){
            
        } else if(Trigger.isAfter){
            opportunityTriggerHandler.rollUpTotalOppOnAccount(Trigger.new);
            opportunityTriggerHandler.rollupHighValueOppONAccount(Trigger.new, null);
        }
    }
    
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            opportunityTriggerHandler.setOppCloseDateandType(Trigger.new, Trigger.oldMap);
        } else if(Trigger.isAfter){
           opportunityTriggerHandler.rollupHighValueOppONAccount(Trigger.new, trigger.oldMap);
        }
    }
    
    if(Trigger.isDelete){
         if(Trigger.isAfter){
            opportunityTriggerHandler.rollUpTotalOppOnAccount(Trigger.old);
             opportunityTriggerHandler.rollupHighValueOppONAccount(Trigger.old, null);
        }
    }
    
    if(Trigger.isUndelete){
        if(Trigger.isAfter){
            opportunityTriggerHandler.rollUpTotalOppOnAccount(Trigger.new);
            opportunityTriggerHandler.rollupHighValueOppONAccount(Trigger.new, null);
        }
    }
}