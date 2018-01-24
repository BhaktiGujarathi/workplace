public class testHtmlTableCtr 
{

public List<wrp> lwrp {get;set;}
public set<String> fieldString {get;set;}
public testHtmlTableCtr() 
{
lwrp = new List<wrp>();
 
lwrp.add( new wrp('11','12'));
lwrp.add( new wrp('21','22'));

fieldString = new set<String>();
fieldString.add('s1');
fieldString.add('s2');

}
public class wrp
{
public String s1 {get;set;}
public String s2 {get;set;}
public wrp(String s1,String s2)
{
this.s1 = s1;
this.s2 = s2;

}

}
}