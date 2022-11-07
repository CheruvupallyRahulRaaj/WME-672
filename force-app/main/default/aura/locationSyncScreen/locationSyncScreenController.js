({
    processSync : function(cmp, evt, hlp) {
        var type = evt.getParam('type');
        var value = evt.getParam('value');
        var syncAndSave = (type === 'sync') ? true : false;
        
        hlp.processSync(cmp, value, syncAndSave);
    },

    checkLocationSyncStatus: function(cmp, evt, hlp) {
        if (evt.getParam('type') === 'status') {
            var value = evt.getParam('value');
            hlp.checkLocationSyncStatus(cmp, value);
        }
    },

    handleSave: function(cmp, evt, hlp) {
        hlp.handleObjectSave(cmp, evt.getParam('value'));
    }
})