public class Scanner {
    public static void scan() {
       // string src='<!DOCTYPE html [<!ENTITY nbsp " ">]>'+source;
       // string src='<table  abd="abc"><tr><td>merul</td><td>Shah</td></tr><tr><td>merul1</td><td>Shah1</td></tr><tr><td>merul2</td><td>Shah2</td></tr></table>';
        
        
        string src='<table class="MsoNormalTable" border="0" cellspacing="0" cellpadding="0" width="308" style="width:231.0pt; margin-left:.1pt; border-collapse:collapse"><tbody><tr style="height:39.0pt"><td width="61" style="width:45.75pt; border:solid windowtext 1.0pt; background:#B6DDE8; padding:0in 5.4pt 0in 5.4pt; height:39.0pt"><p class="MsoNormal"><b><span style="font-size:10pt; font-family:Tahoma,sans-serif">Project Name </span></b></p></td><td width="78" style="width:58.85pt; border:solid windowtext 1.0pt; border-left:none; background:#B6DDE8; padding:0in 5.4pt 0in 5.4pt; height:39.0pt"><p class="MsoNormal"><b><span style="font-size:10pt; font-family:Tahoma,sans-serif">Project Description</span></b></p></td><td width="108" style="width:80.9pt; border:solid windowtext 1.0pt; border-left:none; background:#B6DDE8; padding:0in 5.4pt 0in 5.4pt; height:39.0pt"><p class="MsoNormal"><b><span style="font-size:10pt; font-family:Tahoma,sans-serif">Planned Completion Date</span></b></p></td><td width="61" style="width:45.5pt; border:solid windowtext 1.0pt; border-left:none; background:#B6DDE8; padding:0in 5.4pt 0in 5.4pt; height:39.0pt"><p class="MsoNormal"><b><span style="font-size:10pt; font-family:Tahoma,sans-serif">Stage</span></b></p></td></tr><tr style="height:51.75pt"><td width="61" style="width:45.75pt; border:solid windowtext 1.0pt; border-top:none; padding:0in 5.4pt 0in 5.4pt; height:51.75pt"><p class="MsoNormal"><span style="font-size:10pt; font-family:Tahoma,sans-serif">New Safekey Project</span></p></td><td width="78" style="width:58.85pt; border-top:none; border-left:none; border-bottom:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0in 5.4pt 0in 5.4pt; height:51.75pt"><p class="MsoNormal"><span style="font-size:10pt; font-family:Tahoma,sans-serif">This is a Project for Testing</span></p></td><td width="108" valign="top" style="width:80.9pt; border-top:none; border-left:none; border-bottom:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0in 5.4pt 0in 5.4pt; height:51.75pt"><p class="MsoNormal"><span style="font-size:10pt; font-family:Tahoma,sans-serif">3/21/2014&nbsp;</span></p></td><td width="61" style="width:45.5pt; border-top:none; border-left:none; border-bottom:solid windowtext 1.0pt; border-right:solid windowtext 1.0pt; padding:0in 5.4pt 0in 5.4pt; height:51.75pt"><p class="MsoNormal"><span style="font-size:10pt; font-family:Tahoma,sans-serif">Completed</span></p></td></tr></tbody></table>';
        
        //string src='<table class="MsoNormalTable" border="0" cellspacing="0" cellpadding="0" width="325" style="width:244.0pt;margin-left:-.15pt;border-collapse:collapse"><tbody><tr style="height:15.0pt"><td width="247" nowrap="" valign="bottom" style="width:185.0pt;border:solid windowtext 1.0pt;background:yellow;padding:0in 5.4pt 0in 5.4pt;height:15.0pt"><p class="MsoNormal"><b><span style="color:black">Name</span></b></p></td><td width="79" nowrap="" valign="bottom" style="width:59.0pt;border:solid windowtext 1.0pt;border-left:none;background:yellow;padding:0in 5.4pt 0in 5.4pt;height:15.0pt"><p class="MsoNormal"><b><span style="color:black">Employee #</span></b></p></td></tr><tr style="height:15.0pt"><td width="247" nowrap="" valign="bottom" style="width:185.0pt;border:solid windowtext 1.0pt;border-top:none;padding:0in 5.4pt 0in 5.4pt;height:15.0pt"><p class="MsoNormal"><span style="font-size:9.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:black">Merul</span></p></td><td width="79" nowrap="" valign="bottom" style="width:59.0pt;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0in 5.4pt 0in 5.4pt;height:15.0pt"><p class="MsoNormal"><span style="font-size:9.0pt;font-family:&quot;Arial&quot;,&quot;sans-serif&quot;;color:black">123</span></p></td></tr></tbody></table>';
        String[] values = new String[0];
        src=src.replaceAll('<(br|hr)>','');
         Boolean valueFlag = false;
         src=src.replaceAll('&nbsp;',' ');
         src = src.replaceAll('o:p', 'b');
        src = src.replaceAll('\n', '');
                 
         
        System.debug(System.loggingLevel.Error,src);
        XmlStreamReader r = new XmlStreamReader(src);
        Integer retry = 0;
        Boolean inRow = false, inCol = false;
        List<String> l=new List<String>();
        List<String> t=new List<String>();
          
          List<List<String>> lls=new List<List<String>>();
          
         
        while(r.hasNext() && retry < 3) {
        
            try {
            r.next();
                retry = 0;
                if(r.geteventtype()==xmltag.start_element && r.getlocalname()=='tr') { 
                  
                    inRow = true;
                }
                if(r.geteventtype()==xmltag.end_element && r.getlocalname()=='tr') {
                        t=l.clone();
                        lls.add(t);
                        l.clear();
                    
                    inrow = incol = false;
                }
                if(r.geteventtype()==xmltag.start_element && r.getlocalname()=='td') {
                    incol = true;
                }
                if(r.geteventtype()==xmltag.end_element && r.getlocalname()=='td') {
                    incol = false;
                    if(valueFlag ==true)
                    {valueFlag=false;}else{l.add('NA');}
                    
                }
                if(inRow&&inCol&&r.geteventtype()==xmltag.characters) {
                  
                 // system.debug('$$$$$$$    '+ r.gettext());
                 
                   l.add(r.gettext());
                   valueFlag = true;
                }
                
            } catch(exception e) {
                system.debug('^^^^^^^ '+e);
                retry++;
            }
            
        }
        
    system.debug('%%%%%%    '+lls);
    
     ///// Obtaining a map which includes keys from header of table and values from the respective columns/////////  
        Map < String, List < string >> mapKeyValue = new Map < String, List < string >> ();
        for (integer i = 0; i < lls[0].size(); i++) {
            list < String > s = new list < String > ();
            for (integer j = 1; j < lls.size(); j++) {
                s.add(lls[j][i]);
            }
            mapKeyValue.put(lls[0][i], s);
        }
    System.debug('###########'+mapKeyValue);

    }
    
}