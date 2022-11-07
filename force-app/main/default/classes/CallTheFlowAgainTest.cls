@isTest(SeeAllData=true)
public class CallTheFlowAgainTest {
    
    private static final String flowApiName = 'Dummy_Flow';
    private static final Map<String,Object> inputVariablesMap = new Map<String,Object>{
        'varText' => 'Flows are love!'
    };
    private static final String assertionFailMessagePrefix = 'CallTheFlowAgain Class Assertion Failed: ';

    @IsTest
    static void callSubflowTest(){

        CallTheFlowAgain.FlowInput[] inputs = new CallTheFlowAgain.FlowInput[]{};
        CallTheFlowAgain.FlowInput input = new CallTheFlowAgain.FlowInput();
        input.flowApiName = flowApiName;
        input.inputVariablesJSON = JSON.serialize(inputVariablesMap);
        inputs.add(input);

        Test.startTest();
        CallTheFlowAgain.callSubflow(inputs);
        
        
        Test.stopTest();
        system.debug('Number of SOQL queries '+Limits.getQueries());
        System.assertEquals(
            0, 
            Limits.getQueries(), 
            assertionFailMessagePrefix + 'Number of SOQL queries do not match.'
        );
        
        
    }

}