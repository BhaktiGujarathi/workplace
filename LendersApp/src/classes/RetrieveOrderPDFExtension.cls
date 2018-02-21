public with sharing class RetrieveOrderPDFExtension {
	ApexPages.Standardcontroller cont {get;set;}
	public RetrieveOrderPDFExtension(ApexPages.StandardController controller) {
		cont = controller;
	}
	public PageReference init(){
		NVMSOrderFormExtension ext = new NVMSOrderFormExtension(cont);
		return ext.AttachOrderPDFDocument();
	}
	
}