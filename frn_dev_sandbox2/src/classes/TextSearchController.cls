public with sharing class TextSearchController {
	
    public String getJSON(){
		String name = Apexpages.currentPage().getParameters().get('name');
		List<WrapperClass> wrpList = new List<WrapperClass>();
		
		if(name.trim() != null){
			String keyTerm = '%'+name.trim()+'%';
			for(Account acc:[Select id, name from Account where name like :keyTerm]){
				wrpList.add(new WrapperClass(string.valueof(acc.id), acc.name, 'Referral Source'));
			}
			for(Contact con: [Select id, name from Contact where firstname like :keyTerm or lastname like:keyTerm ]){
				wrpList.add(new WrapperClass(string.valueof(con.id), con.name, 'Referral Source Contact'));
			}
			
		}
		
        return JSON.serialize(wrpList);
    }
    
	public class WrapperClass
	{
		String ids,label,category;

		public WrapperClass(String wrid, String name, String category)
		{
			this.label = name;
			this.ids = wrid;
			this.category = category;
		}
	}

}