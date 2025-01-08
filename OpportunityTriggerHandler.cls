public class OpportunityTriggerHandler {
    public static void oppAmountDesc(List<Opportunity> newOppList){
        
        for(Opportunity opp: newOppList){
            if(opp.Amount!=null && opp.Amount>10000){
                opp.Description='Hot Opportunity';
            }
        }
        
    }
    
    public static void latestOppAmount(List<Opportunity> newOppList){ 
        
        Map<Id, Opportunity> latestOppMap = new Map<Id, Opportunity>();
        
        
        for(Opportunity opp: [ SELECT Id,AccountId,Name, Amount, CloseDate 
                              FROM Opportunity WHERE AccountId = : 
                              newOppList[0].AccountId ORDER BY CreatedDate DESC]){
            
            if(!latestOppMap.containsKey(opp.AccountId)){
                latestOppMap.put(opp.AccountId, opp);
            }
        }
        
        List<Account> accToUpdate = new List<Account>();
        
        for(Opportunity opp: latestOppMap.values()){
            Account acc=new Account();
            acc.Id=opp.AccountId;
            
            acc.Recent_Opportunity_Amount__c=opp.Amount;
            accToUpdate.add(acc);
                
        }
        Update accToUpdate;
    }
    
    
    public static void OppDelUserPermission(List<Opportunity> oldOppList){
        
        List<User> Profile_ID= [select ProfileId from User 
                        where Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        
        
        for(Opportunity opp: oldOppList){
            if(opp.StageName=='Close Won' || opp.StageName=='Close Lost'){ 
                
                if(UserInfo.getProfileId() != Profile_ID[0].ProfileId){
                
                    opp.addError('Cannot Delete by Non Admin User');
                    
                    }
            }
        }
            
        
        
    }
    
    
    public static void OppAmountToAnnualRevenue(List<Opportunity> newOppList){
        Map<Id, Decimal> annualRevenueMap = new map<id, Decimal>();
        
        Set<Id> accIds = new Set<Id>();
        for(Opportunity opp : newOppList){
            if(opp.AccountId!=null && opp.Amount !=null){
                accIds.add(opp.AccountId);
                System.debug(accIds);
            }
            
        }
        
        for(Opportunity opp: [SELECT Id, Amount, AccountId FROM Opportunity WHERE AccountId =:accIds]){
            
            if(annualRevenueMap.containsKey(opp.AccountId)){
                annualRevenueMap.put(opp.AccountId, annualRevenueMap.get(opp.AccountId)+opp.Amount);
            }
            else{
                annualRevenueMap.put(opp.AccountId, opp.Amount);
            }
        }
       
        List<Account> accList = new List<Account>();
        for(Account acc : [SELECT Id, AnnualRevenue FROM Account WHERE Id IN:annualRevenueMap.keySet()]){
            acc.AnnualRevenue = annualRevenueMap.get(acc.Id);
            accList.add(acc);
            
        }
        
        if(!accList.isEmpty()){
            //System.debug('Empty Annual Revenue');
            Update accList;
        }
    }
    
    
}