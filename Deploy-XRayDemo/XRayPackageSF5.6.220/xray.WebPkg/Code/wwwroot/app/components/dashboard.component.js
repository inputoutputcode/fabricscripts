System.register(["angular2/core", "angular2/router", "rxjs/Rx", "./clustercapacitygraph.component", "./clustercapacitydonut.component", "./../services/data.service", "./../viewmodels/clustercapacityviewmodel", "./../viewmodels/clusterinfoviewmodel", "./../viewmodels/list"], function (exports_1, context_1) {
    "use strict";
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
    var core_1, router_1, Rx_1, clustercapacitygraph_component_1, clustercapacitydonut_component_1, data_service_1, clustercapacityviewmodel_1, clusterinfoviewmodel_1, list_1, DashboardComponent, DataStreamSubscription;
    return {
        setters: [
            function (core_1_1) {
                core_1 = core_1_1;
            },
            function (router_1_1) {
                router_1 = router_1_1;
            },
            function (Rx_1_1) {
                Rx_1 = Rx_1_1;
            },
            function (clustercapacitygraph_component_1_1) {
                clustercapacitygraph_component_1 = clustercapacitygraph_component_1_1;
            },
            function (clustercapacitydonut_component_1_1) {
                clustercapacitydonut_component_1 = clustercapacitydonut_component_1_1;
            },
            function (data_service_1_1) {
                data_service_1 = data_service_1_1;
            },
            function (clustercapacityviewmodel_1_1) {
                clustercapacityviewmodel_1 = clustercapacityviewmodel_1_1;
            },
            function (clusterinfoviewmodel_1_1) {
                clusterinfoviewmodel_1 = clusterinfoviewmodel_1_1;
            },
            function (list_1_1) {
                list_1 = list_1_1;
            }
        ],
        execute: function () {
            DashboardComponent = (function () {
                function DashboardComponent(dataService, router) {
                    this.dataService = dataService;
                    this.router = router;
                    this.clusterCapacities = [];
                    this.selectedClusterCapacities = [];
                    this.dataStreams = [];
                    this.clusterCapacityStream = new Rx_1.ReplaySubject();
                    Chart.defaults.global.maintainAspectRatio = false;
                    Chart.defaults.global.defaultFontFamily = "'Segoe UI', 'Segoe', Arial, sans-serif";
                    Chart.defaults.global.defaultFontSize = 10;
                    Chart.defaults.global.defaultFontColor = "#AAAAAA";
                    Chart.defaults.global.tooltips.cornerRadius = 0;
                }
                DashboardComponent.prototype.ngOnInit = function () {
                    var _this = this;
                    this.clusterInfoSubscription = this.dataService.getClusterInfo().subscribe(function (result) {
                        if (!result) {
                            return;
                        }
                        _this.clusterInfo = new clusterinfoviewmodel_1.ClusterInfoViewModel(result.healthStatus, result.version, result.nodeTypes, result.applicationTypes, result.faultDomains, result.upgradeDomains, dateFormat(result.lastBalanceStartTime, 'mm/dd/yy HH:mm:ss'), dateFormat(result.lastBalanceEndTime, 'mm/dd/yy HH:mm:ss'), result.nodes, result.applications, result.services, result.partitions, result.replicas);
                        console.log("got cluster info.");
                    }, function (error) { return console.log("error from observable: " + error); });
                    this.clusterCapacitySubscription = this.dataService.getClusterCapacity().subscribe(function (result) {
                        if (!result) {
                            return;
                        }
                        list_1.List.updateList(_this.clusterCapacities, result.map(function (x) {
                            return new clustercapacityviewmodel_1.ClusterCapacityViewModel(x.bufferedCapacity, x.capacity, x.load, x.remainingBufferedCapacity, x.remainingCapacity, x.isClusterCapacityViolation, x.name, x.bufferPercentage, x.balancedBefore, x.balancedAfter, x.deviationBefore, x.deviationAfter, x.balancingThreshold, x.maxLoadedNode, x.minLoadedNode, true);
                        }));
                        var _loop_1 = function (i) {
                            var item = _this.dataStreams[i];
                            if (!_this.clusterCapacities.find(function (x) { return x.name == item.name; })) {
                                _this.removeDataStream(item.name);
                            }
                        };
                        for (var i = 0; i < _this.dataStreams.length; ++i) {
                            _loop_1(i);
                        }
                        _this.clusterCapacities.forEach(function (x) {
                            if (x.selected) {
                                _this.createDataStream(x.name);
                            }
                        });
                    }, function (error) { return console.log("error from observable: " + error); });
                };
                DashboardComponent.prototype.ngOnDestroy = function () {
                    if (this.clusterInfoSubscription) {
                        this.clusterInfoSubscription.unsubscribe();
                    }
                    if (this.clusterCapacitySubscription) {
                        this.clusterCapacitySubscription.unsubscribe();
                    }
                    for (var i = 0; i < this.dataStreams.length; ++i) {
                        var item = this.dataStreams[i];
                        this.removeDataStream(item.name);
                    }
                };
                DashboardComponent.prototype.createDataStream = function (name) {
                    if (!this.dataStreams.find(function (item) { return item.name == name; })) {
                        console.log("subscribing to " + name);
                        var replay_1 = new Rx_1.ReplaySubject();
                        var subscription = this.dataService.getClusterCapacityHistory(name).subscribe(function (next) { return replay_1.next(next); }, function (error) { return replay_1.error(error); });
                        this.dataStreams.push(new DataStreamSubscription(name, subscription, replay_1));
                        this.clusterCapacityStream.next(new clustercapacitygraph_component_1.DataStream(name, replay_1));
                    }
                };
                DashboardComponent.prototype.removeDataStream = function (name) {
                    var ix = this.dataStreams.findIndex(function (x) { return x.name == name; });
                    if (ix >= 0) {
                        var dataStream = this.dataStreams[ix];
                        dataStream.subject.complete();
                        dataStream.subject.unsubscribe();
                        dataStream.subscription.unsubscribe();
                        this.dataStreams.splice(ix, 1);
                    }
                };
                DashboardComponent.prototype.onSelectCapacity = function (name, event) {
                    var isChecked = event.currentTarget.checked;
                    if (isChecked) {
                        this.createDataStream(name);
                    }
                    else {
                        this.removeDataStream(name);
                    }
                };
                DashboardComponent.prototype.isCapacityWarning = function (item) {
                    return item.capacity > 0 && item.load / item.capacity > 0.9;
                };
                return DashboardComponent;
            }());
            DashboardComponent = __decorate([
                core_1.Component({
                    selector: 'dashboard-component',
                    templateUrl: 'app/components/dashboard.component.html',
                    styleUrls: ['app/components/dashboard.component.css'],
                    directives: [clustercapacitygraph_component_1.ClusterCapacityGraph, clustercapacitydonut_component_1.ClusterCapacityDonut]
                }),
                __metadata("design:paramtypes", [data_service_1.DataService,
                    router_1.Router])
            ], DashboardComponent);
            exports_1("DashboardComponent", DashboardComponent);
            DataStreamSubscription = (function () {
                function DataStreamSubscription(name, subscription, subject) {
                    this.name = name;
                    this.subscription = subscription;
                    this.subject = subject;
                }
                return DataStreamSubscription;
            }());
        }
    };
});
//# sourceMappingURL=dashboard.component.js.map