trigger AccountTrigger on Account (before insert, after Insert, before Update, after update, before Delete) {

    if(Trigger.isInsert){
        if(Trigger.isBefore){
           AccountTriggerHandler.preventDuplicationOfAccountName(Trigger.new, null);
        } else if(Trigger.isAfter){
            AccountTriggerHandler.createdRelatedContact(Trigger.new);
            AccountTriggerHandler.createdRelatedContactWithsamePhone(Trigger.new);
            AccountTriggerHandler.CreateNumberOfContactsAsNumberOfLocationValue(Trigger.new);
            AccountTriggerHandler.create3relatedContacts(Trigger.new);
        }
    }
    
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            AccountTriggerHandler.preventDuplicationOfAccountName(Trigger.new, trigger.oldMap);
            AccountTriggerHandler.updateDescription(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.sendEmailToOwner(Trigger.new, Trigger.oldMap);
        }
        else if(Trigger.isAfter){
            AccountTriggerHandler.changeRelatedConLastName(Trigger.new, Trigger.oldMap);
        }
    }
    
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            AccountTriggerHandler.preventDeletionOfAccHavingOpp(Trigger.old);
        }
    }
}