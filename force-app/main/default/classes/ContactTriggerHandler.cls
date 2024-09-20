// 1. When a new contact is created add account phone number in new contact other phone field.
public class ContactTriggerHandler {
    
    public static void addAccPhoneOnContact(List<Contact> conList){
        Set<Id> accIds = new Set<Id>();
        Map<Id, Account> accMap = new Map<Id, Account>();
        for(Contact con : conList){
            accIds.add(con.AccountId);
        }
        
        for(Account acc:[Select Id, Name, Phone,(Select Id, AccountId, HomePhone from Contacts)
                         from Account where Id IN: accIds]){
                             accMap.put(acc.Id, acc); 
                             
        if(accMap.containsKey(acc.Id)){
            for(Contact con: acc.Contacts){
                if(con.AccountId != null){
                    con.HomePhone =  accMap.get(acc.Id).Phone; 
                }
            }
        }
       }
    }
    
    // 2. After Insert Trigger For Count of Contacts rollup on Account
    public static void rollupContactOnAccount(List<Contact> conList){
        Set<Id> accIds = new Set<Id>();
        List<Account> accList = new List<Account>();
        for(Contact con : conList){
            if(con.AccountId != null){
                accIds.add(con.AccountId);
            }
            
            for(Account acc: [Select Id,Name,Total_Contact_Count__c,(Select Id, AccountId from Contacts)
                              from Account where Id IN:accIds]){
                                  
              acc.Total_Contact_Count__c = acc.Contacts.size();
              accList.add(acc);
                              }
            if(!accList.isEmpty()){
                update accList;
            }
        }
    }
    
    // 3. Duplicate Check on Existing Contact if Phone number is already Present
    public static void checkDuplicationOfrecordIfPhoneissame(List<Contact> conList){
    //Unique number: Set to hold phone numbers of new contacts
      Set<String> newconPhoneSet = new Set<String>();
        // Map to hold existing contacts with their phone numbers
        Map<String, Contact> conPhoneMap = new Map<String, Contact>();
        
        for(Contact con : conList){
            if(con.Phone != null){
                newconPhoneSet.add(con.Phone);
            }
        }

        for(Contact con : [Select Id, AccountId, Phone from Contact where Phone IN: newconPhoneSet]){
            conPhoneMap.put(con.Phone, con);
        }
        
        for(Contact con : conList){
            if(con.Phone != null && conPhoneMap.containsKey(con.Phone)){
                con.addError('You Can not create Contact with same Phone Number');
            }
        }
    }
}