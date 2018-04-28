@isTest
private class BillingCalloutServiceTest {
  //Implement mock callout tests here
 	@testSetup
   	static void testsetup(){
        Opportunity opp = new Opportunity(Name = 'test opp',
                                         CloseDate = Date.today(),
                                         StageName = 'Prospecting');
        insert opp;
        Project__c prj = new Project__c(Name = 'test project',
                                       Opportunity__c = opp.Id,
                                       Status__c = 'Running',
                                       Billable_Amount__c = 1000,
                                       ProjectRef__c = 'testref');
        insert prj;
        ServiceCredentials__c serv_cred = new ServiceCredentials__c();
        serv_cred.Name = 'BillingServiceCredential';
        serv_cred.Username__c = 'bsUser1';
        serv_cred.Password__c = 'bsPass1';
        insert serv_cred;
   	}
    
   	@isTest
    static void testCalloutsuccess(){
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
        Project__c prj = [Select Id, ProjectRef__c, Status__c, Billable_Amount__c
                          from Project__c where Name = 'test project' limit 1];
        Test.startTest();
        prj.Status__c = 'Billable';
        update prj;
        Test.stopTest();
        prj = [Select Id, Status__c from Project__c where Name = 'test project' limit 1];
        System.assertEquals('Billed', prj.Status__c);
        
    }
        
   	@isTest
    static void testCalloutFailure(){
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
        Project__c prj = [Select Id, ProjectRef__c, Status__c, Billable_Amount__c
                          from Project__c where Name = 'test project' limit 1];
        Test.startTest();
        prj.Status__c = 'Billable';
        update prj;
        Test.stopTest();
        prj = [Select Id, Status__c from Project__c where Name = 'test project' limit 1];
        System.assertEquals('Running', prj.Status__c);
    }
}