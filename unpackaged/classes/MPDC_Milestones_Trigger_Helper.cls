public class MPDC_Milestones_Trigger_Helper {
    
    Set<ID> minorProjectIDSet=new Set<ID>();
    Map<ID, String> milestoneDateMap=new Map<ID, String>();
    Map<ID, String> minorProjectMap=new Map<ID,String>();
    Map<ID, String> minorProjectAreaMap=new Map<ID,String>();
    Map<ID, String> minorProjectAssetGrpMap=new Map<ID,String>();
    Map<ID, ID> minorProjectSubTowerMap=new Map<ID,ID>();  /*Modify by Bhanu 06-04-2018. Map was <Id, String> but I have changed it for <Id, Id>*/
    Map<String,MPDC_Capacity_Tracker__c> capacityMap=new Map<String, MPDC_Capacity_Tracker__c>();
    Map<ID,MPDC_Capacity_Tracker__c> milestoneVsCapacityMap=new Map<ID, MPDC_Capacity_Tracker__c>();
    Map<String,MPDC_Capacity_Tracker__c> capacityAssetGrpMap=new Map<String, MPDC_Capacity_Tracker__c>();
    Map<String,MPDC_Capacity_Tracker__c> capacityAreaMap=new Map<String, MPDC_Capacity_Tracker__c>();
    Map<String,MPDC_Capacity_Tracker__c> capacitySubtowerMap=new Map<String, MPDC_Capacity_Tracker__c>();
    List<MPDC_Capacity_Tracker__c> capacityUpdate=new List<MPDC_Capacity_Tracker__c>();
    MPDC_Capacity_Tracker__c milestoneCapacity=new MPDC_Capacity_Tracker__c();
    Boolean capacityFound=false;
    
    public void searchCapacity(Map<MPDC_Milestones__c,String> milestones){
        System.debug('Inside search capacity method');
        System.debug('MileStones KeySet==>'+milestones.keySet());
        System.debug('MileStones values==>'+milestones.values());  
        for(MPDC_Milestones__c milestone : milestones.keySet()) 
        {
            minorProjectIDSet.add(milestone.MPDC_Minor_Project__c);
            String mon_year=milestone.MPDC_Milestone_Month__c+milestone.MPDC_Milestone_Year__c;
            System.debug('inside first foreach loop in searchCapacity method mon_year==>'+mon_year);
            milestoneDateMap.put(milestone.ID,mon_year);
        }
        System.debug('minorProjectIDSet===>'+minorProjectIDSet);
        System.debug('milestoneDateMap==>'+milestoneDateMap);
        
         /*Added by bhanu singh start 06-04-2018*/
        List<MPDC_Minor_Project__c> minorProjectDetails = [Select ID, MPDC_Asset_Name__c , MPDC_Asset_Name__r.MPDC_Area__c,MPDC_Asset_Name__r.MPDC_hddn_Sub_Tower__c,MPDC_Asset_Name__r.MPDC_Asset_Group__c from MPDC_Minor_Project__c where ID IN : minorProjectIDSet];
        System.debug('minorProjectDetails in search method====>'+minorProjectDetails); 
        /*Added by bhanu singh end 06-04-2018*/
        
        for(MPDC_Minor_Project__c minorProject:[Select ID, MPDC_Asset_Name__c , MPDC_Asset_Name__r.MPDC_Area__c,MPDC_Asset_Name__r.MPDC_hddn_Sub_Tower__c,MPDC_Asset_Name__r.MPDC_Asset_Group__c from MPDC_Minor_Project__c where ID IN : minorProjectIDSet]){
            
            minorProjectMap.put(minorProject.ID,minorProject.MPDC_Asset_Name__c);
            System.debug('minorProject Asset name is ==>'+minorProject.MPDC_Asset_Name__c);
            
            minorProjectAreaMap.put(minorProject.ID, minorProject.MPDC_Asset_Name__r.MPDC_Area__c);
            if(minorProject.MPDC_Asset_Name__r.MPDC_Asset_Group__c!=null){
                minorProjectAssetGrpMap.put(minorProject.ID, minorProject.MPDC_Asset_Name__r.MPDC_Asset_Group__c);
            }
            //minorProjectSubTowerMap.put(minorProject.ID, minorProject.MPDC_Asset_Name__r.MPDC_hddn_Sub_Tower__c);    /*Old Change*/
            
            /*Code Modify by Bhanu 06-04-2018 start*/
            
            String capSubTowerName =  minorProject.MPDC_Asset_Name__r.MPDC_hddn_Sub_Tower__c;
            String query1 ='Select Id, Name from MPDC_Sub_Tower__c where Name =: capSubTowerName';
            System.debug('query1=='+query1);
            MPDC_Sub_Tower__c subTower = Database.query(query1);
            System.debug('record=='+subTower.id);
            minorProjectSubTowerMap.put(minorProject.ID, subTower.id);   /*New change added by Bhanu*/
            /*Code Modify by Bhanu 06-04-2018 end*/
        }
        
        System.debug('minor project map is '+ minorProjectMap);
        System.debug('minor project map values is '+ minorProjectMap.values());
        System.debug('minor project area map is '+ minorProjectAreaMap);
         System.debug('minor project asset map is '+ minorProjectAssetGrpMap);
        System.debug('minor project sub tower map is '+ minorProjectSubTowerMap);
        System.debug('minor project sub tower map value is '+ minorProjectSubTowerMap.values());
        
         /*code Modify by Bhanu 06-06-2018 start*/
        List<MPDC_Minor_Project__c> minProj =  [Select ID, MPDC_Asset_Name__c,MPDC_Request_Type__c from MPDC_Minor_Project__c where ID IN : minorProjectIDSet];  
        if (minorProjectMap.size()>0){

        List<MPDC_Capacity_Tracker__c>  capacityTracker = [Select ID,MPDC_Capacity_Type__c,MPDC_Total_Capacity__c,MPDC_vailable_Capacity__c,MPDC_Utilized_Capacity__c,MPDC_Month__c,MPDC_Year__c, MPDC_Asset__c from MPDC_Capacity_Tracker__c where MPDC_Asset__c in : minorProjectMap.values()];
        for(MPDC_Capacity_Tracker__c cap : capacityTracker)
        {
            String mon_year=cap.MPDC_Month__c+cap.MPDC_Year__c;
            System.debug('capacity===>'+cap);
            System.debug('mon_year====>'+mon_year);
            Id minProjId;
            for(MPDC_Minor_Project__c min : minProj){
                If(min.MPDC_Asset_Name__c.equals(cap.MPDC_Asset__c)){
                  minProjId = min.Id;
                }
            }  
            System.debug('minProjId===>'+minProjId);
            
            MPDC_Minor_Project__c minorProj = [Select Id, MPDC_Request_Type__c from MPDC_Minor_Project__c where ID =: minProjId]; 
            If(cap.MPDC_Capacity_Type__c.equals(minorProj.MPDC_Request_Type__c)){
              System.debug('MinorProject RequestType and CapactiyTracker Capacity Type is equal.... ');
              capacityMap.put(mon_year,cap);
            }  
         }
          
        /*code Modify by Bhanu 06-06-2018 end*/
        /*   Code commented on 06-06-2018
        for (MPDC_Capacity_Tracker__c capacity: [Select ID,MPDC_Capacity_Type__c,MPDC_Total_Capacity__c,MPDC_vailable_Capacity__c,MPDC_Utilized_Capacity__c,MPDC_Month__c,MPDC_Year__c, MPDC_Asset__c from MPDC_Capacity_Tracker__c where MPDC_Asset__c in : minorProjectMap.values()])
        {
            String mon_year=capacity.MPDC_Month__c+capacity.MPDC_Year__c;
            System.debug('capacity===>'+capacity);
            System.debug('mon_year====>'+mon_year);
            capacityMap.put(mon_year,capacity);
        }
        */
        }
        
         if (minorProjectAssetGrpMap.size()>0){
        for (MPDC_Capacity_Tracker__c capacity: [Select ID,MPDC_Capacity_Type__c,MPDC_Total_Capacity__c,MPDC_vailable_Capacity__c,MPDC_Utilized_Capacity__c,MPDC_Month__c,MPDC_Year__c, MPDC_Asset_Group__c from MPDC_Capacity_Tracker__c where MPDC_Asset_Group__c in : minorProjectAssetGrpMap.values()])
        {
            String mon_year=capacity.MPDC_Month__c+capacity.MPDC_Year__c;
            capacityAssetGrpMap.put(mon_year,capacity);
        }
         }
        
             if (minorProjectAreaMap.size()>0){
        for (MPDC_Capacity_Tracker__c capacity: [Select ID,MPDC_Capacity_Type__c,MPDC_Total_Capacity__c,MPDC_vailable_Capacity__c,MPDC_Utilized_Capacity__c,MPDC_Month__c,MPDC_Year__c, MPDC_Area__c from MPDC_Capacity_Tracker__c where MPDC_Area__c in : minorProjectAreaMap.values()])
        {
            String mon_year=capacity.MPDC_Month__c+capacity.MPDC_Year__c;
            capacityAreaMap.put(mon_year,capacity);
        }
             }
        
        if (minorProjectSubTowerMap.size()>0){
        System.debug('Inside in minorProjectSubTowerMap.size()>0 ');
        for (MPDC_Capacity_Tracker__c capacity: [Select ID,MPDC_Capacity_Type__c,MPDC_Total_Capacity__c,MPDC_vailable_Capacity__c,MPDC_Utilized_Capacity__c,MPDC_Month__c,MPDC_Year__c, MPDC_Sub_Tower__c  from MPDC_Capacity_Tracker__c where MPDC_Sub_Tower__c in : minorProjectSubTowerMap.values()])
        {
           /*code Modify by Bhanu 06-06-2018 start*/
            System.debug('capacity insdie subTower====>'+capacity);
            String mon_year=capacity.MPDC_Month__c+capacity.MPDC_Year__c;
            
            
            for(MPDC_Minor_Project__c min : minProj)
            {
             If(min.MPDC_Request_Type__c.equals(capacity.MPDC_Capacity_Type__c)){
               System.debug('MinorProject RequestType and CapactiyTracker Capacity Type is equal inside minorProjectSubTowerMap.size()>0.... ');
               capacitySubtowerMap.put(mon_year,capacity);     
             }
            }
            
          /*code Modify by Bhanu 06-06-2018 end*/
        }
        }
        
        System.debug('capacity assset is'+capacityMap.keySet());
        System.debug('capacity assset values is=='+capacityMap.values());
        System.debug('capacity area is'+capacityAreaMap);
        System.debug('capacity grp is'+capacityAssetGrpMap);
        System.debug('capacity sub tower is'+capacitySubtowerMap);
        System.debug('capacity sub tower map values is'+capacitySubtowerMap.values());
        for(MPDC_Milestones__c milestone : milestones.keySet()){
            System.debug('inside for loop1');
            String milestone_date=milestoneDateMap.get(milestone.ID);
            System.debug('milestone_date=='+milestone_date);
            if(capacityMap.size()>0 && capacityMap.containsKey(milestone_date)){
                System.debug('inside for loop1+condition 1');
                MPDC_Capacity_Tracker__c capacity=capacityMap.get(milestone_date);
                System.debug('capacity.MPDC_Capacity_Type__c inside for loop1+condition 1 =='+capacity.MPDC_Capacity_Type__c);
                String type=milestones.get(milestone);
                System.debug('Type inside for loop1+condition 1 =='+type);
                if(capacity.MPDC_Capacity_Type__c==type){
                    System.debug('inside for loop1+condition 2');
                milestoneVsCapacityMap.put(milestone.ID,capacity);
                System.debug('Capacity found is '+capacity);
                    
                capacityFound=true;
                    
                }
            }
            else if(capacityAssetGrpMap.size()>0 && capacityAssetGrpMap.containsKey(milestone_date)) {
                 System.debug('inside for loop1+condition 1');
                MPDC_Capacity_Tracker__c capacity=capacityAssetGrpMap.get(milestone_date);
                String type=milestones.get(milestone);
                if(capacity.MPDC_Capacity_Type__c==type){
                     System.debug('inside for loop1+condition 2');
                milestoneVsCapacityMap.put(milestone.ID,capacity);
                System.debug('Capacity found is '+capacity);
                    
                capacityFound=true;
                    
                }
            }
            else if(capacityAreaMap.size()>0 && capacityAreaMap.containsKey(milestone_date)) {
                 System.debug('inside for loop1+condition 3');
                MPDC_Capacity_Tracker__c capacity=capacityAreaMap.get(milestone_date);
                String type=milestones.get(milestone);
                if(capacity.MPDC_Capacity_Type__c==type){
                     System.debug('inside for loop1+condition 3');
                milestoneVsCapacityMap.put(milestone.ID,capacity);
                System.debug('Capacity found is '+capacity);
                    
                capacityFound=true;
                    
                }
            }
            
            else if(capacitySubtowerMap.size()>0 && capacitySubtowerMap.containsKey(milestone_date)) {
                 System.debug('inside for loop1+condition 4');
                MPDC_Capacity_Tracker__c capacity=capacitySubtowerMap.get(milestone_date);
                System.debug('capacity inside loop1+condition 4==> '+capacity);
                String type=milestones.get(milestone);
                if(capacity.MPDC_Capacity_Type__c==type){
                     System.debug('inside for loop1+condition 4');
                milestoneVsCapacityMap.put(milestone.ID,capacity);
                System.debug('Capacity found is '+capacity);
                    
                capacityFound=true;
                    
                }
            }
            else{
                if(capacityFound==false){
                    System.debug('Capacity not defined');
                    milestone.addError('Capacity not defined');
                }
            }
            
            
        }
    }
    
    public void insertMilestone(List<MPDC_Milestones__c> milestones){
        for(MPDC_Milestones__c milestone: milestones){
            if(milestoneVsCapacityMap.containsKey(milestone.ID)){
                MPDC_Capacity_Tracker__c cap= milestoneVsCapacityMap.get(milestone.ID);
                System.debug('Capacity is '+cap);
                System.debug('Available Capacity is'+cap.MPDC_vailable_Capacity__c);
                if(milestone.MPDC_Total_Effort_hrs__c<=cap.MPDC_vailable_Capacity__c){
                    if(cap.MPDC_Utilized_Capacity__c!=null){
                        cap.MPDC_Utilized_Capacity__c= cap.MPDC_Utilized_Capacity__c+milestone.MPDC_Total_Effort_hrs__c;   
                    }
                    else{
                        cap.MPDC_Utilized_Capacity__c= milestone.MPDC_Total_Effort_hrs__c;
                    }
                    capacityUpdate.add(cap);
                }
                else{
                    milestone.addError('Total Capacity for Milestone is greater than Avilable Capacity!!');
                }
            }
            else{
                milestone.addError('Capacity not Defined!!');
                
            }
        }
        if(capacityUpdate.size()>0){
            update capacityUpdate;
        }
        
    }
    
    public void updateMilestone(List<MPDC_Milestones__c> milestones, Map<ID,MPDC_Milestones__c> oldMap)   {
        System.debug('Inside update method');
        for(MPDC_Milestones__c milestone: milestones){
            MPDC_Milestones__c oldMilestone= oldMap.get(milestone.ID);
            if(milestoneVsCapacityMap.containsKey(milestone.ID)){
                MPDC_Capacity_Tracker__c cap= milestoneVsCapacityMap.get(milestone.ID);
                System.debug('Capacity is '+cap);
                System.debug('Available Capacity is'+cap.MPDC_vailable_Capacity__c);
                System.debug('Old milestone total capacity='+oldMilestone.MPDC_Total_Effort_hrs__c);
                if(oldMilestone.MPDC_Total_Effort_hrs__c<milestone.MPDC_Total_Effort_hrs__c){
                    System.debug('Value of condition true or false'+(cap.MPDC_vailable_Capacity__c>=milestone.MPDC_Total_Effort_hrs__c));
                    if(cap.MPDC_vailable_Capacity__c>=milestone.MPDC_Total_Effort_hrs__c){
                        System.debug('Value of condition true or false'+(cap.MPDC_vailable_Capacity__c>=milestone.MPDC_Total_Effort_hrs__c));
                        if(cap.MPDC_Utilized_Capacity__c!=null){
                            cap.MPDC_Utilized_Capacity__c= cap.MPDC_Utilized_Capacity__c+milestone.MPDC_Total_Effort_hrs__c-oldMilestone.MPDC_Total_Effort_hrs__c;   
                        }
                        else{
                            cap.MPDC_Utilized_Capacity__c= milestone.MPDC_Total_Effort_hrs__c;
                        }
                        capacityUpdate.add(cap);
                    }
                    else{
                        System.debug('Inside error else block');
                        milestone.addError('Total Capacity for Milestone is greater than Avilable Capacity!!');
                    } 
                    
                }
                else if(oldMilestone.MPDC_Total_Effort_hrs__c>milestone.MPDC_Total_Effort_hrs__c){
                    cap.MPDC_Utilized_Capacity__c= cap.MPDC_Utilized_Capacity__c+milestone.MPDC_Total_Effort_hrs__c-oldMilestone.MPDC_Total_Effort_hrs__c;   
                    capacityUpdate.add(cap);
                }
                
            }
            else{
                milestone.addError('Capacity not Defined!!');
            }
        }
        if(capacityUpdate.size()>0){
            update capacityUpdate;
        }
    }
    public void deleteMilestone(List<MPDC_Milestones__c> milestones){
         System.debug('Inside delete method');
        System.debug('milestone is:'+milestones);
        for(MPDC_Milestones__c milestone:milestones){
            System.debug('milestone is:'+ milestone);
            if(milestoneVsCapacityMap.containsKey(milestone.ID)){
                MPDC_Capacity_Tracker__c cap= milestoneVsCapacityMap.get(milestone.ID);                
                 System.debug('Capacity is '+cap);
                 System.debug('Utilized capacity before deletion'+cap.MPDC_Utilized_Capacity__c);
                System.debug('total capacity before deletion'+milestone.MPDC_Total_Effort_hrs__c);
                cap.MPDC_Utilized_Capacity__c= cap.MPDC_Utilized_Capacity__c-milestone.MPDC_Total_Effort_hrs__c;   
                 System.debug('Utilized capacity after deletion'+cap.MPDC_Utilized_Capacity__c);
                capacityUpdate.add(cap);
            }
            
            else{
                milestone.addError('Capacity not Defined!!');
                
            }
        }
        if(capacityUpdate.size()>0){
             System.debug('Capcity update');
            update capacityUpdate;
        }
    }
}