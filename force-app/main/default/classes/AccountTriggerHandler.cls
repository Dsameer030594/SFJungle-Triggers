public class AccountTriggerHandler {
    // 1. If the Account phone number field has been updated, populate the description field of the 
    //same Account with previous and new phone nos.
    public static void updateDescription(List<Account> accList, Map<Id, Account> accOldMap){
        
        for(Account acc : accList){
            if(acc.Phone != accOldMap.get(acc.Id).Phone){
                acc.Description = 'Your Account Phone Number has been changed ! old Phone no is: ' + accOldMap.get(acc.Id).Phone + '  new Phone No is : ' + acc.Phone;
            }
        }
    }
    // 2. If industry and rating has been updated in an Account send email to account owner with change details including old and 
    //new industry and rating
    public static void sendEmailToOwner(List<Account> accList, Map<Id, Account> accOldMap){
        // Map<Id, Account> accMap = new Map<Id, Account>();
        Set<Id> ownerIdSet= new Set<Id>();
        
        for(Account acc : accList){
            //if industry and rating has been updated send email to acc owner with change details
            if(acc.Industry != accOldMap.get(acc.Id).Industry && acc.Rating != accOldMap.get(acc.Id).Rating){
                //accMap.put(acc.Id, acc);
                ownerIdSet.add(acc.OwnerId); 
            }
        }
        //if owner id set is not empty method to create and send email to all owners for each
        //of their individual accounts with details about the change in the rating and industry of Account
        //userId Email Map
        
        Map<Id, String> emailIdsMap=new Map<Id, String>();
        if(ownerIdSet.size()>0 && ownerIdSet!=null){
            for(User us:[SELECT Id, Email FROM User WHERE Id IN:ownerIdSet]){
                if(ownerIdSet.contains(us.Id)){
                    emailIdsMap.put(us.Id, us.Email);
                }
            }
        }
        List<Messaging.SingleEmailMessage> mailList= new List<Messaging.SingleEmailMessage>();
        for(Account acc : accList){
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{emailIdsMap.get(acc.OwnerId)});
            mail.setSubject('Account Update for '+acc.Name);
            mail.setPlainTextBody('Alert! The rating and industry of Account: '+acc.Name+
                                  ' has been changed from old Rating: '+accOldMap.get(acc.Id).Rating+
                                  ' to new Rating: '+acc.Rating+' and old Industry: '+accOldMap.get(acc.Id).Industry+ ' to new Industry: '+acc.Industry);
            mailList.add(mail);
        }
        if(!mailList.isEmpty() && mailList.size()>0){
            Messaging.sendEmail(mailList, false);
        }
    }
    
    // 3. Duplicate check to prevent new Account creation if new Name is same as existing Name
    public static void preventDuplicationOfAccountName(List<Account> accList, Map<Id, Account> accOldMap){
        Set<String> accNameSet = new Set<String>();
        // Map<Id, String> existingNameMap = new Map<Id, String>();
        Map<String, Account> existingNameMap = new Map<String, Account>();
        
        for(Account acc : accList){
            if(acc.Name != null && acc.Name != accOldMap.get(acc.Id).Name){
                accNameSet.add(acc.Name); 
            }
        }
        
        for(Account acc :[Select Id, Name from Account where Name IN: accNameSet]){
            if(accNameSet.size() >0){
                existingNameMap.put(acc.Name, acc);
            }
        }
        for(Account acc : accList){
            if(acc.Name != null && existingNameMap.containsKey(acc.Name)){
                acc.Name.addError('Duplicate Account exists!');
            }
        }
    }
    
    // 4. Prevent delete of an account with more than 2 opportunities and opportunities having amount greater than 4000
    public static void preventDeletionOfAccHavingOpp(List<Account> accList){
        // Collecting Account Ids being deleted
        Set<Id> accLids = new Set<Id>();
        
        // Querying for Opportunities related to the Accounts being deleted
        Map<Id, Integer> opportunityCountMap  = new Map<Id, Integer>();
        
        for(Account acc : accList){
            accLids.add(acc.Id); 
        }
        
        for(Opportunity opp :[Select Id, AccountId, Amount from Opportunity where AccountId IN:accLids AND Amount > 4000]){
            opportunityCountMap.put(opp.AccountId, 1);
        }
        // Checking for Accounts with more than 2 opportunities
        //  with amounts greater than 4000
        for(Account acc : accList){
            if(opportunityCountMap.containsKey(acc.Id) && opportunityCountMap.get(acc.Id) > 2){
                acc.addError('Cannot delete this account. It has more than 2 opportunities with amounts greater than 4000.');
            }
        }
    }
    
    // 5. Whenever Account name is changed it’s related Contact Lastname should be updated to the new account name
    public static void changeRelatedConLastName(List<Account> accList, Map<Id, Account> accOldMap){
        List<Contact> conList = new List<Contact>();
        Map<Id, Account> accMap = new Map<Id, Account>();
        for(Account acc : accList){
            if(acc.Name!= null && acc.Name != accOldMap.get(acc.Id).Name){
                accMap.put(acc.Id, acc);
            }
        }
        for(Contact con: [Select Id, AccountId, LastName from Contact where AccountId IN:accMap.keySet()]){
            if(accMap.containsKey(con.AccountId)){
                con.LastName = accMap.get(con.AccountId).Name + ' ' + con.LastName;
                conList.add(con); 
            }  
        }
        if(!conList.isEmpty()){   
            update conList;
        }
    }
    // 6. After new account creation create 3 new contacts associate them with the new account, and contact name should be: 
    //AccName+CurrentDateTime+unique serial number
    
    public static void create3relatedContacts(List<Account> accList){
        List<Contact> conList = new List<Contact>();
        //Map<Id, Account> accNewMap=Trigger.newMap;
        
        for(Account acc : accList){
            // Create 3 contacts for each new account
            for(Integer i = 1; i<=3; i++){
                Contact con = new Contact();
                con.FirstName =  'Test';
                con.LastName = acc.Name + '' +  DateTime.now().format('yyyyMMdd') + '' + String.valueOf(i);
                con.AccountId = acc.Id;
                conList.add(con);
            }
        }
        
        insert conList;
        
    }
    // 3.Whenever New Account Record is created then needs to create associated Contact Record automatically.
    
    public static void createdRelatedContact(List<Account> accList){
        
        List<Contact> conList = new List<Contact>();
        for(Account acc : accList){
            Contact con = new Contact();
            con.FirstName = 'Test';
            con.LastName = acc.Name;
            con.Phone = acc.Phone;
            con.AccountId = acc.Id;
            conList.add(con);   
        }
        if(!conList.isEmpty()){
            insert conList;
        }
    }
    
    //4.Whenever the Account is created with Industry as Banking then create a 
    //contact for account, Contact Lastname as Account name and contact phone as account phone.
    
    public static void createdRelatedContactWithsamePhone(List<Account> accList){
        List<Contact> conList = new List<Contact>();
        
        for(Account acc : accList){
            if(acc.Industry == 'Banking'){
                Contact con = new Contact();
                con.FirstName = 'Test';
                con.LastName = acc.Name;
                con.Phone = acc.Phone;
                con.AccountId = acc.Id;
                conList.add(con);
            }
        }
        if(!conList.isEmpty()){
            insert conList;
        }
    }
    
    // Trigger Scenario 5 :Creates the number of contacts which are equal to 
    // the number which we will enter in the Number of Locations field on the Account Object.
    public static void CreateNumberOfContactsAsNumberOfLocationValue(List<Account> accList){
        // List to hold new Contact records
        List<Contact> conList = new List<Contact>();
        
        // Iterate through the newly inserted Account records
        for(Account acc : accList){
            if(acc.NumberofLocations__c != null && acc.NumberofLocations__c >0){
                // Create contacts based on the value of "Number of Locations"
                for(Integer i = 0; i< acc.NumberofLocations__c; i++){
                    Contact con = new Contact();
                    con.LastName = 'Contact ' + (i+1); // Set a unique name for each contact
                    con.AccountId = acc.Id;
                    conList.add(con);
                }
            }
        }
        if(!conList.isEmpty()){    // Insert the newly created contacts
            insert conList;
        }
    }
    // Important 2. If industry and rating has been updated in an Account send email to account owner with change details
    // including old andnew industry and rating
    public static void sendEmailToAccOwner(List<Account> accList, Map<Id, Account> accOldMap){
        
        Set<Id> accIds = new Set<Id>();
        
        //if industry and rating has been updated send email to acc owner with change details
        for(Account acc : accList){
            if(accOldMap != null && acc.Industry != accOldMap.get(acc.Id).Industry && acc.Rating != accOldMap.get(acc.Id).Rating){
                accIds.add(acc.OwnerId);
            }
        }
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        //if owner id set is not empty method to create and send email to all owners for each
        //of their individual accounts with details about the change in the rating and industry of Account
        for(Account acc : [Select Id, OwnerId, Name from Account Where OwnerId IN: accIds]){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String> {acc.OwnerId});
            email.setSubject('your Industry and Rating updated');
            email.setPlainTextBody('Alert! The Rating and Industry of Account : ' + acc.Name+ 'Has been change from old Rating '+ accOldMap.get(acc.Id).Rating + 'To new Rating ' + acc.Rating
                                   + 'And Old Industry ' +  accOldMap.get(acc.Id).Industry + 'to new Industry: ' + acc.Industry);
            
            emailList.add(email);
        }
        Messaging.sendEmail(emailList, false);
    }
}