public class testTransientController {

 public Transient string testVar{get; set;} 
 
 public testTransientController ()
 {
   testVar= 'Hiii';
 
 }
 
 public pagereference go()
 {
 
   system.debug('%%%%% '+testVar);
   return null;
 
 }
 
}