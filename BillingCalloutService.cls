public class BillingCalloutService {
    //Implement business and callout logic methods here
    public static void callBillingService(List<Project__c> newprojects, Map<Id, Project__c> oldprojects){
        List<Project__c> projects = [Select Id, ProjectRef__c, Status__c, Billable_Amount__c
                                     from Project__c where Status__c = 'Billable' and Id IN:newprojects];
        //Custom settings for SOAP credentials
        String username = ServiceCredentials__c.getValues('BillingServiceCredential').Username__c;
        String password = ServiceCredentials__c.getValues('BillingServiceCredential').Password__c;
        for(Project__c prj:projects){
            if(oldprojects.get(prj.Id).Status__c != 'Billable'){
                Asyncmakecallout(username, password, prj.ProjectRef__c, (Double)prj.Billable_Amount__c);
            }
        }
    }
    @future(callout = true)
    public static void Asyncmakecallout(String username, String password, 
                                        String projectRef, Double amount){
		BillingServiceProxy.project project_instance = new BillingServiceProxy.project();
		project_instance.username = username;
		project_instance.password = password;
		project_instance.projectRef = projectRef;
		project_instance.billAmount = amount;                                            
		BillingServiceProxy.InvoicesPortSoap11 billingservice = new BillingServiceProxy.InvoicesPortSoap11();
		String result = billingservice.billProject(project_instance);	
		system.debug('result: '+ result);  
		Project__c prj = [Select Id, Status__c from Project__c where ProjectRef__c =:projectRef limit 1];                                            
		if(result == 'ok'){
            prj.Status__c = 'Billed';
            update prj;
        }
		else{
            prj.Status__c = 'Running';
            update prj;
        }                                                                           
    }
}