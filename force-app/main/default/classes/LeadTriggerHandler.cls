public class LeadTriggerHandler {
// 2.Whenever Lead is created with LeadSource as Web then give rating as cold otherwise hot.

    public static void setLeadRating(List<Lead> leadList){
        
        for(Lead ld : leadList){
            if(ld.LeadSource == 'Web'){
                ld.Rating = 'Cold';
            }else {
                ld.Rating = 'Hot';
            }
        }
    }
}