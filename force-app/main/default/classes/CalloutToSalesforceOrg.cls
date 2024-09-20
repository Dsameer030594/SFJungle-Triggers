public class CalloutToSalesforceOrg {

    public static void getAccounts(){
        // Whenever you create Http class, you have to create Three Different Methods
        // 1. Http class
        // 2. HttpRequest Class
        // 3. HttpResponse Class
        
        //method 1
        Http http = new Http();
        
        //method 2
        Httprequest request = new Httprequest();
        //in this request you have to set endPoint  // take help from Postman or remember these thing
         // 'callout:name of named Crenditials/services/apexrest/urlMapping'
        
        request.setEndPoint('callout:SFDCB/services/apexrest/accountMGMt/');
        //Set Method
        request.setMethod('GET');
        
        //method 3
        Httpresponse response = http.send(request);
        
        System.debug('response'+ response.getBody());
        System.debug('response status'+ response.getStatusCode());
        
        if(response.getStatusCode() == 200){
            List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
            for(Object obj : results){
                System.debug(obj);
            }
        } else{
            System.debug('Error in Integration' + response.getBody());
        }
    }
}