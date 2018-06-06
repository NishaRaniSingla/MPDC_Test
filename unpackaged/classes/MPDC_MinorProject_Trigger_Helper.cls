public class MPDC_MinorProject_Trigger_Helper {

    public static void copyAssetSMEToLillySMEApprover(List<MPDC_Minor_Project__c> triggerList){
        Set<Id> assetNameId= new Set<Id>();
        Map<Id,Id> minorProjectToAssetName = new Map<Id,Id>();
        Map<Id,List<Id>> assetToSMEMap = new Map<Id,List<Id>>();
        Integer ApproverNumber;
        for(MPDC_Minor_Project__c temp:triggerList){
            if(temp.MPDC_Asset_Name__c != null){
                assetNameId.add(temp.MPDC_Asset_Name__c);
                minorProjectToAssetName.put(temp.Id,temp.MPDC_Asset_Name__c);
            }
        }
        List<MPDC_Asset__c> assetList =[select Id ,(select MPDC_Person_Name__c from Asset_SMEs__r ORDER BY CreatedDate DESC limit 10) from MPDC_Asset__c where Id in:assetNameId];
        if(assetList != null){
            for(MPDC_Asset__c tempAsset :assetList){
                if(tempAsset.Asset_SMEs__r != null){
                for(MPDC_Asset_SME__c tempSME : tempAsset.Asset_SMEs__r){
                    if(assetToSMEMap.containsKey(tempAsset.Id)){
                        if(tempSME.MPDC_Person_Name__c != null){
                            assetToSMEMap.get(tempAsset.Id).add(tempSME.MPDC_Person_Name__c);
                        }
                    }else{
                        assetToSMEMap.put(tempAsset.Id, new List<Id>{tempSME.MPDC_Person_Name__c});
                    }//end of else 
                }//end of for
              }//end of if
            }//end of for
        }
        for(MPDC_Minor_Project__c tempMP: triggerList){
            List<Id> finalAssetSMEIdList = assetToSMEMap.get(minorProjectToAssetName.get(tempMP.Id));
            ApproverNumber = 1;
            if(finalAssetSMEIdList != null){
                for(Id tempAssetSMEId : finalAssetSMEIdList){
                    tempMP.put('MPDC_LillyManager_SME_Approver'+String.valueOf(ApproverNumber)+'__c',tempAssetSMEId);
                    ApproverNumber++;
                }//end of for
                for(Integer tempVar = ApproverNumber;tempVar <=10;tempVar++ ){
                   tempMP.put('MPDC_LillyManager_SME_Approver'+String.valueOf(tempVar)+'__c',finalAssetSMEIdList.get(0));
               } 
            }//end of if
            
            else{
                
                for(Integer tempVar = ApproverNumber;tempVar <=10;tempVar++ ){
                    
                    tempMP.put('MPDC_LillyManager_SME_Approver'+String.valueOf(tempVar)+'__c',tempMP.MPDC_Manager__c);
                }
                
            }
        }
      }//End of function
      
      public  static void approverComments(List<MPDC_Minor_Project__c> triggerList){
          Set<Id> minorProjectIds =new Set<Id>();
          Map<Id,MPDC_Minor_Project__c> minorProjectIdToObject=new Map<Id, MPDC_Minor_Project__c>();
          for(MPDC_Minor_Project__c temp:triggerList){
               minorProjectIds.add(temp.Id);
               minorProjectIdToObject.put(temp.Id,temp);
            }
            system.debug('------>Size of Minor Project List'+minorProjectIds.size());
            
            List<ProcessInstance> currentApprovalList =[select Id, TargetObjectId ,(SELECT Id, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC LIMIT 1 ) from ProcessInstance where TargetObjectId in : minorProjectIds];
            system.debug('------>Size of Minor Project List'+currentApprovalList.size());
            
             if(currentApprovalList != null){
             for(ProcessInstance temp : currentApprovalList ){
                 system.debug('------>'+temp.Steps[0].StepStatus);
                 system.debug('------>'+temp.Steps[0].Comments);
                 if(temp.Steps[0].StepStatus == 'Removed' || temp.Steps[0].StepStatus == 'Approved' || temp.Steps[0].StepStatus == 'Rejected'){
                     if ((temp.Steps[0].Comments == null || temp.Steps[0].Comments.trim().length() == 0)){
                         minorProjectIdToObject.get(temp.TargetObjectId).addError('Please proivde your comments');
                     }//end of comments if
                }//end of blank if
                }
            }// end of currentApproval if
      }
    public static void copySubTowerMembersToApprover(List<MPDC_Minor_Project__c> triggerList){
        List<String> groupNames = new List<String>();
        String groupNamePrefix = 'MPDC_';
        String groupNameSuffix = '_Admins';
        Integer remainingFieldIndex;
        Map<Id, String> minorProjectToSubTowerMap = new Map<Id, String>();
        Map<Id,MPDC_Minor_Project__c> minorProjectIdTObject =new Map<Id,MPDC_Minor_Project__c>();
        Map<String,Id> groupNameToId = new Map<String,Id>();
        Map<Id,List<GroupMember>> groupIdToMembers = new Map<Id,List<GroupMember>>();
        Map<Id,List<GroupMember>> minorProjectIdToMembers = new Map<Id,List<GroupMember>>();
        for(MPDC_Minor_Project__c temp: triggerList){
        
            System.debug('++++>'+temp.MPDC_Sub_Tower__c);  // Problem with this field. 
            
            groupNames.add(groupNamePrefix + temp.MPDC_Sub_Tower__c + groupNameSuffix);
            minorProjectToSubTowerMap.put(temp.Id,groupNamePrefix + temp.MPDC_Sub_Tower__c + groupNameSuffix);
            System.debug('------>'+temp.Id+'---'+groupNamePrefix + temp.MPDC_Sub_Tower__c + groupNameSuffix);
            minorProjectIdTObject.put(temp.Id,temp);
        }    
        
        List<Group> groupNameList = [Select Id,Name, (Select UserorGroupId from GroupMembers ) from Group where Name in : groupNames];
        System.debug('------>'+groupNameList.size());
        if(groupNameList != null){
            for(Group tempGroup:groupNameList ){
                System.debug('------>'+tempGroup.Name+'----'+tempGroup.Id);
                System.debug('------>'+tempGroup.Name+'----'+tempGroup.GroupMembers);
                groupNameToId.put(tempGroup.Name, tempGroup.Id);
                groupIdToMembers.put(tempGroup.Id, tempGroup.GroupMembers);
            } 
        }//groupNamelist if 
        for(MPDC_Minor_Project__c tempMinor : triggerList){
            System.debug('tempMinor.MPDC_Minor_Project_Status__c========>'+tempMinor.MPDC_Minor_Project_Status__c);  //added by bhanu on 06-06-2018
            System.debug('------>Minor Project Id'+tempMinor.id+'---->List of Members'+groupIdToMembers.get(groupNameToId.get(minorProjectToSubTowerMap.get(tempMinor.Id))));
            minorProjectIdToMembers.put(tempMinor.id,groupIdToMembers.get(groupNameToId.get(minorProjectToSubTowerMap.get(tempMinor.Id))));

            /*Inside below if condition block... Bhanu has added a one condition more that is tempMinor.MPDC_Minor_Project_Status__c!='Draft'. So that validation for no member available in sub tower will not fire for Draft state. change date 06-06-2018*/
            if(tempMinor.MPDC_Minor_Project_Status__c=='Draft')
            {
              System.debug('Draft state no validation will fire');
            }
            else if(minorProjectIdToMembers.get(tempMinor.Id) != null && minorProjectIdToMembers.get(tempMinor.Id).size() > 0){
            for(Integer SubTowerAdminApprover = 1;SubTowerAdminApprover <= minorProjectIdToMembers.get(tempMinor.Id).size();SubTowerAdminApprover++){
              System.debug('------>MPDC_SubTowerAdminApprover'+String.valueOf(SubTowerAdminApprover)+'__c'+'---Value'+minorProjectIdToMembers.get(tempMinor.Id).get(SubTowerAdminApprover-1).Id); 
                tempMinor.put('MPDC_SubTowerAdminApprover'+String.valueOf(SubTowerAdminApprover)+'__c',minorProjectIdToMembers.get(tempMinor.Id).get(SubTowerAdminApprover-1).UserorGroupId);
                remainingFieldIndex = SubTowerAdminApprover;
                }//for Integer SubTower
               for(Integer tempVar = remainingFieldIndex + 1;tempVar <=10;tempVar++ ){
                   tempMinor.put('MPDC_SubTowerAdminApprover'+String.valueOf(tempVar)+'__c',minorProjectIdToMembers.get(tempMinor.Id).get(0).UserorGroupId);
               } 
            }// if minorProjectIdToMembers
            else{
                tempMinor.addError('There are no member available in the SubTower. Please add member to continue');
            }
        }
    }
}