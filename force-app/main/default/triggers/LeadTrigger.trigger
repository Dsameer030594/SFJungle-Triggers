trigger LeadTrigger on Lead (before insert) {

    if(Trigger.isInsert){
        if(Trigger.isBefore){
            LeadTriggerHandler.setLeadRating(Trigger.new);
        }
    }
}