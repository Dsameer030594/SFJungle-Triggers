trigger CaseTrigger on Case (before insert) {

    if(Trigger.isInsert){
        if(Trigger.isBefore){
            CaseTriggerHandler.setCaseStatusandPriority(Trigger.new);
        }
    }
}