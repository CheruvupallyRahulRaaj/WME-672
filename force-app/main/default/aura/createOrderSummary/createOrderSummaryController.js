({
    init : function(cmp, evt, hlp) {
        // if the recordId and sObjectName are set, this cmp was triggered from a quick account, 
        // let's retrieve the account based on the Id
        hlp.setAccount(cmp);
    },
    processReq : function(cmp, evt, hlp) {
		hlp.processRequest(cmp);
    },
    handleCreateOrderScreenChange : function(cmp, evt) {
        if (evt.getParam('type') === 'createorder') {
            var value = evt.getParam('value');
            cmp.set('v.payload', value);
        }
    }
})