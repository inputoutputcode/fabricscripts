System.register(["./../data.service", "angular2/core", "rxjs/Rx", "./mock-data", "./../../models/deployedapplication", "./../../models/deployedservice", "./../../models/clustercapacityhistory"], function (exports_1, context_1) {
    "use strict";
    var __extends = (this && this.__extends) || (function () {
        var extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return function (d, b) {
            extendStatics(d, b);
            function __() { this.constructor = d; }
            d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
        };
    })();
    var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
        var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
        if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
        else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
        return c > 3 && r && Object.defineProperty(target, key, r), r;
    };
    var __metadata = (this && this.__metadata) || function (k, v) {
        if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
    };
    var __moduleName = context_1 && context_1.id;
    var data_service_1, core_1, Rx_1, mock_data_1, deployedapplication_1, deployedservice_1, clustercapacityhistory_1, MockDataService;
    return {
        setters: [
            function (data_service_1_1) {
                data_service_1 = data_service_1_1;
            },
            function (core_1_1) {
                core_1 = core_1_1;
            },
            function (Rx_1_1) {
                Rx_1 = Rx_1_1;
            },
            function (mock_data_1_1) {
                mock_data_1 = mock_data_1_1;
            },
            function (deployedapplication_1_1) {
                deployedapplication_1 = deployedapplication_1_1;
            },
            function (deployedservice_1_1) {
                deployedservice_1 = deployedservice_1_1;
            },
            function (clustercapacityhistory_1_1) {
                clustercapacityhistory_1 = clustercapacityhistory_1_1;
            }
        ],
        execute: function () {
            MockDataService = (function (_super) {
                __extends(MockDataService, _super);
                function MockDataService() {
                    var _this = _super.call(this) || this;
                    _this.refreshInterval = 20;
                    _this.history = {};
                    var now = Date.now();
                    for (var _i = 0, ClusterCapacityList_1 = mock_data_1.ClusterCapacityList; _i < ClusterCapacityList_1.length; _i++) {
                        var capacity = ClusterCapacityList_1[_i];
                        var items = [];
                        for (var i = 0; i < 50; ++i) {
                            items.push(new clustercapacityhistory_1.ClusterCapacityHistory(new Date(now - (60000 * (50 - i))), Math.random() * 1000));
                        }
                        _this.history[capacity.name] = items;
                    }
                    return _this;
                }
                MockDataService.prototype.getApplicationModels = function (nodeName, appTypeFilter) {
                    return Rx_1.Observable
                        .interval(this.refreshInterval * 1000)
                        .startWith(-1)
                        .flatMap(function () {
                        var result = [];
                        var filter = appTypeFilter();
                        console.log("getting application types: " + filter.join(','));
                        var appList = filter
                            ? mock_data_1.ApplicationList.filter(function (x) { return filter.indexOf(x.type) < 0; })
                            : mock_data_1.ApplicationList;
                        for (var i = 0; i < appList.length; ++i) {
                            var app = new deployedapplication_1.DeployedApplication();
                            app.application = appList[i];
                            app.services = [];
                            for (var _i = 0, _a = mock_data_1.ServiceList[app.application.name]; _i < _a.length; _i++) {
                                var item = _a[_i];
                                var serviceModel = new deployedservice_1.DeployedService();
                                serviceModel.service = item;
                                serviceModel.replicas = mock_data_1.ReplicaList[serviceModel.service.name];
                                app.services.push(serviceModel);
                            }
                            result.push(app);
                        }
                        return Rx_1.Observable.of(result);
                    });
                };
                MockDataService.prototype.getClusterCapacityHistory = function (capacityName, startDate) {
                    var _this = this;
                    var start = startDate ?
                        startDate :
                        new Date(Date.now() - 3600000);
                    return Rx_1.Observable
                        .interval(this.refreshInterval * 1000)
                        .startWith(-1)
                        .flatMap(function () {
                        var o = Rx_1.Observable.of(_this.history[capacityName].filter(function (x) { return x.timestamp > start; }));
                        start = new Date(Date.now());
                        return o;
                    });
                };
                MockDataService.prototype.getClusterCapacity = function () {
                    return Rx_1.Observable
                        .interval(this.refreshInterval * 1000)
                        .startWith(-1)
                        .flatMap(function () { return Rx_1.Observable.of(mock_data_1.ClusterCapacityList); });
                };
                MockDataService.prototype.getNodes = function (nodeTypeFilter) {
                    return Rx_1.Observable
                        .interval(this.refreshInterval * 1000)
                        .startWith(-1)
                        .flatMap(function () {
                        var nodeTypes = nodeTypeFilter();
                        return nodeTypes
                            ? Rx_1.Observable.of(mock_data_1.ClusterNodeList.filter(function (x) { return nodeTypes.indexOf(x.nodeType) < 0; }))
                            : Rx_1.Observable.of(mock_data_1.ClusterNodeList);
                    });
                };
                MockDataService.prototype.getNodeCapacity = function (nodeName) {
                    return Rx_1.Observable
                        .interval(this.refreshInterval * 1000)
                        .startWith(-1)
                        .flatMap(function () { return Rx_1.Observable.of(mock_data_1.ClusterNodeCapacityList[nodeName]); });
                };
                MockDataService.prototype.getClusterFilters = function () {
                    return Rx_1.Observable
                        .interval(this.refreshInterval * 1000)
                        .startWith(-1)
                        .flatMap(function () { return Rx_1.Observable.of(mock_data_1.ClusterFiltersData); });
                };
                MockDataService.prototype.getClusterInfo = function () {
                    return Rx_1.Observable
                        .interval(this.refreshInterval * 1000)
                        .startWith(-1)
                        .flatMap(function () { return Rx_1.Observable.of(mock_data_1.ClusterInfoData); });
                };
                return MockDataService;
            }(data_service_1.DataService));
            MockDataService = __decorate([
                core_1.Injectable(),
                __metadata("design:paramtypes", [])
            ], MockDataService);
            exports_1("MockDataService", MockDataService);
        }
    };
});
//# sourceMappingURL=mockdata.service.js.map