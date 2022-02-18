System.register([], function (exports_1, context_1) {
    "use strict";
    var __moduleName = context_1 && context_1.id;
    var ClusterInfoViewModel;
    return {
        setters: [],
        execute: function () {
            ClusterInfoViewModel = (function () {
                function ClusterInfoViewModel(healthStatus, version, nodeTypes, applicationTypes, faultDomains, upgradeDomains, lastBalanceStartTime, lastBalanceEndTime, nodes, applications, services, partitions, replicas) {
                    this.healthStatus = healthStatus;
                    this.version = version;
                    this.nodeTypes = nodeTypes;
                    this.applicationTypes = applicationTypes;
                    this.faultDomains = faultDomains;
                    this.upgradeDomains = upgradeDomains;
                    this.lastBalanceStartTime = lastBalanceStartTime;
                    this.lastBalanceEndTime = lastBalanceEndTime;
                    this.nodes = nodes;
                    this.applications = applications;
                    this.services = services;
                    this.partitions = partitions;
                    this.replicas = replicas;
                }
                return ClusterInfoViewModel;
            }());
            exports_1("ClusterInfoViewModel", ClusterInfoViewModel);
        }
    };
});
//# sourceMappingURL=clusterinfoviewmodel.js.map