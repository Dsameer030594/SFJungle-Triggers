public class opportunityTriggerHandler {
    
    //Trigger Scenario 6 :Whenever Opportunity "Stage" is modified to "Closed Won" 
    //then set "Close Date" as "Today Date" and "Type" as "New Customer".
    public static void setOppCloseDateandType(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        
        for(Opportunity opp : oppList){
            // Check if the Stage has been changed to "Closed Won"
            if(opp.StageName != oppOldMap.get(opp.Id).StageName && opp.StageName == 'Closed Won' && oppOldMap.get(opp.Id).StageName != 'Closed Won'){
                opp.CloseDate = System.Today();
                opp.Type = 'New Customer';
            }
        }
    }
    
    // Roll up total number of opportunities under each account after Opportunity is created, deleted or undeleted
    
    public static void rollUpTotalOppOnAccount(List<Opportunity> oppList){
        Set<Id> accIds = new Set<Id>();
        List<Account> accList =  new List<Account>();
        
        for(Opportunity opp : oppList){
            if(opp.AccountId != null){
                accIds.add(opp.AccountId);
            }
        }
        
        for(Account acc : [Select Id, Name, Total_Opportunity_Count__c,(Select Id, Name, StageName from Opportunities) from Account where Id IN:accIds]){
            acc.Total_Opportunity_Count__c = acc.Opportunities.size();
            accList.add(acc);  
        }
        
        update accList;
    }
    // Roll up count of High Valued opportunities under parent account for 
    // each opportunity with amount>5000 and Stage='Closed Won' when Opportunity is created, deleted or 
    // undeleted and when the Opportunity is updated and amount changes and amount >5000 and Stage changes to 'Closed Won'
    
    public static void rollupHighValueOppONAccount(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        List<Account> accList = new List<Account>();
        Set<Id> accIds =  new Set<Id>();
        
        for(Opportunity opp : oppList){
            if(opp.AccountId != null && opp.Amount >= 5000 && opp.StageName == 'Closed Won' && opp.StageName != oppOldMap.get(opp.Id).StageName){
                accIds.add(opp.AccountId);
            }
        }
        
        for(Account acc :[Select Id, Name, High_Value_Opportunities__c,(Select Id, AccountId, Amount, StageName from Opportunities)from Account where Id IN: accIds]){
            
            acc.High_Value_Opportunities__c =  acc.Opportunities.size();
            accList.add(acc);
        }
        update accList;
    }
    // Roll up sum of amount of each opportunity with StageName=='Negotiation/Review' under parent account after
    //insert, delete or undelete and when the Opportunity is updated and amount is not empty and amount changes and Stage
    //changes to 'Negotiation/Review' OR Stage is
    //'Negotiation/Review' and amount changes but is not 0 or null or negative
    
    public static void UpdateNegotiationReviewAmountSum(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        Set<Id> accIds = new Set<Id>();
        List<Account> accList = new List<Account>();
        Map<Id, Opportunity> oppNewMap = new Map<Id, Opportunity>();
        
        // Collect Account Ids based on the Opportunity criteria
        for(Opportunity opp : oppList){
             if ((opp.StageName == 'Negotiation/Review' && opp.Amount != null) ||   // for insert, delete , undelete
            (opp.Amount != null && opp.Amount != oppOldMap.get(opp.Id).Amount && 
             opp.StageName == 'Negotiation/Review' && opp.StageName != oppOldMap.get(opp.Id).StageName)) {  // for update
            accIds.add(opp.AccountId);
        }
             // Query and calculate sum for each Account
             
            for(Account acc :[Select Id, Name, NegotiationReviewAmountSum__c, 
                              (Select Id, AccountId, Amount, StageName from Opportunities WHERE StageName = 'Negotiation/Review') 
                              from Account where Id IN: accIds]){
                                  Decimal sumAmount = 0;
                                  for (Opportunity opp1 : acc.Opportunities) {
                                      if (opp1.Amount != null && opp1.Amount > 0) {
                                          sumAmount += opp1.Amount;
                                      }
                                  }
                                  acc.NegotiationReviewAmountSum__c = sumAmount;
                                  accList.add(acc);   
                              }
            
            update accList;
        }
        
    }
}