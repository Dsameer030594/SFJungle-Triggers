trigger ContactTrigger on Contact (before insert, before update, after Insert, after delete, after undelete) {

    if(Trigger.isInsert){
        if(Trigger.isBefore){
            ContactTriggerHandler.addAccPhoneOnContact(Trigger.new);
            ContactTriggerHandler.checkDuplicationOfrecordIfPhoneissame(Trigger.new);
        } else if(Trigger.isAfter){
            ContactTriggerHandler.rollupContactOnAccount(Trigger.new);
        }
    }
    
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            ContactTriggerHandler.checkDuplicationOfrecordIfPhoneissame(Trigger.new);
        }
    }
    if(Trigger.isDelete){
        if(Trigger.isAfter){
          ContactTriggerHandler.rollupContactOnAccount(Trigger.old);  
        }
    }
    
    if(Trigger.isUndelete){
        if(Trigger.isAfter){
             ContactTriggerHandler.rollupContactOnAccount(Trigger.new);  
        }
    }
}