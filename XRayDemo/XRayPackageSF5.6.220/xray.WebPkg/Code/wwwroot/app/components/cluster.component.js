System.register(["angular2/core", "angular2/router", "./node.component", "./../viewmodels/selectable", "./../viewmodels/nodeviewmodel", "./../viewmodels/clustercapacityviewmodel", "./../viewmodels/clusterinfoviewmodel", "./../viewmodels/list", "./../services/data.service"], function (exports_1, context_1) {
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
    var core_1, router_1, node_component_1, selectable_1, nodeviewmodel_1, clustercapacityviewmodel_1, clusterinfoviewmodel_1, list_1, data_service_1, ClusterComponent;
    return {
        setters: [
            function (core_1_1) {
                core_1 = core_1_1;
            },
            function (router_1_1) {
                router_1 = router_1_1;
            },
            function (node_component_1_1) {
                node_component_1 = node_component_1_1;
            },
            function (selectable_1_1) {
                selectable_1 = selectable_1_1;
            },
            function (nodeviewmodel_1_1) {
                nodeviewmodel_1 = nodeviewmodel_1_1;
            },
            function (clustercapacityviewmodel_1_1) {
                clustercapacityviewmodel_1 = clustercapacityviewmodel_1_1;
            },
            function (clusterinfoviewmodel_1_1) {
                clusterinfoviewmodel_1 = clusterinfoviewmodel_1_1;
            },
            function (list_1_1) {
                list_1 = list_1_1;
            },
            function (data_service_1_1) {
                data_service_1 = data_service_1_1;
            }
        ],
        execute: function () {
            ClusterComponent = (function () {
                function ClusterComponent(dataService, router) {
                    this.dataService = dataService;
                    this.router = router;
                    this.DefaultCapacitySize = 500;
                    this.selectedColors = 'status';
                    this.selectedMetricName = "Count";
                    this.scaleFactor = 1;
                    this.maxCapacityCount = 0;
                    this.applicationsExpanded = true;
                    this.servicesExpanded = true;
                    this.nodes = [];
                    this.selectedNodeTypes = [];
                    this.selectedApplicationTypes = [];
                    this.clusterCapacities = [];
                }
                ClusterComponent.prototype.ngOnInit = function () {
                    var _this = this;
                    this.nodeSubscription = this.dataService.getNodes(function () { return _this.selectedNodeTypes.length > 0 ? _this.selectedNodeTypes.filter(function (x) { return !x.selected; }).map(function (x) { return x.name; }) : null; }).subscribe(function (result) {
                        if (!result) {
                            return;
                        }
                        list_1.List.updateList(_this.nodes, result.map(function (x) {
                            return new nodeviewmodel_1.NodeViewModel(x.name, x.nodeType, x.status.toLowerCase(), x.healthState.toLowerCase(), x.upTime, x.address, x.faultDomain, x.upgradeDomain, true, true);
                        }));
                    }, function (error) { return console.log("error from observable: " + error); });
                    this.clusterFiltersSubscription = this.dataService.getClusterFilters().subscribe(function (result) {
                        if (!result) {
                            return;
                        }
                        list_1.List.updateList(_this.selectedNodeTypes, result.nodeTypes.map(function (x) { return new selectable_1.Selectable(x, true); }));
                        list_1.List.updateList(_this.selectedApplicationTypes, result.applicationTypes.map(function (x) { return new selectable_1.Selectable(x, true); }));
                    }, function (error) { return console.log("error from observable: " + error); });
                    this.clusterSubscription = this.dataService.getClusterCapacity().subscribe(function (result) {
                        if (!result) {
                            return;
                        }
                        list_1.List.updateList(_this.clusterCapacities, result.map(function (x) {
                            return new clustercapacityviewmodel_1.ClusterCapacityViewModel(x.bufferedCapacity, x.capacity, x.load, x.remainingBufferedCapacity, x.remainingCapacity, x.isClusterCapacityViolation, x.name, x.bufferPercentage, x.balancedBefore, x.balancedAfter, x.deviationBefore, x.deviationAfter, x.balancingThreshold, x.maxLoadedNode, x.minLoadedNode, true);
                        }));
                        _this.selectedClusterCapacity = _this.clusterCapacities.find(function (x) { return x.name == _this.selectedMetricName; });
                    }, function (error) { return console.log("error from observable: " + error); });
                    this.clusterInfoSubscription = this.dataService.getClusterInfo().subscribe(function (result) {
                        if (!result) {
                            return;
                        }
                        _this.clusterInfo = new clusterinfoviewmodel_1.ClusterInfoViewModel(result.healthStatus, result.version, result.nodeTypes, result.applicationTypes, result.faultDomains, result.upgradeDomains, dateFormat(result.lastBalanceStartTime, 'mm/dd/yy HH:mm:ss'), dateFormat(result.lastBalanceEndTime, 'mm/dd/yy HH:mm:ss'), result.nodes, result.applications, result.services, result.partitions, result.replicas);
                        console.log("got cluster info.");
                    }, function (error) { return console.log("error from observable: " + error); });
                };
                ClusterComponent.prototype.ngOnDestroy = function () {
                    if (this.clusterInfoSubscription) {
                        this.clusterInfoSubscription.unsubscribe();
                    }
                    if (this.nodeSubscription) {
                        this.nodeSubscription.unsubscribe();
                    }
                    if (this.clusterSubscription) {
                        this.clusterSubscription.unsubscribe();
                    }
                    if (this.clusterFiltersSubscription) {
                        this.clusterFiltersSubscription.unsubscribe();
                    }
                };
                ClusterComponent.prototype.onChangeCapacity = function (newValue) {
                    var _this = this;
                    // select change event gives index:value, but other places it's just the value. Nice.
                    var ix = newValue.indexOf(":");
                    this.selectedMetricName = ix >= 0
                        ? newValue.slice(ix + 1).trim()
                        : newValue;
                    this.selectedClusterCapacity = this.clusterCapacities.find(function (x) { return x.name == _this.selectedMetricName; });
                };
                ClusterComponent.prototype.onChangeColors = function (newValue) {
                    this.selectedColors = newValue;
                };
                ClusterComponent.prototype.onSelectNodeType = function (nodeType, event) {
                    // Deselecting a node type will remove it from the data stream,
                    // but that takes a few seconds to update.
                    // This removes it from the list immediately to make the UI more responsive.
                    var isChecked = event.currentTarget.checked;
                    if (!isChecked) {
                        var ix = -1;
                        while ((ix = this.nodes.findIndex(function (x) { return x.nodeType == nodeType; })) >= 0) {
                            this.nodes.splice(ix, 1);
                        }
                    }
                };
                ClusterComponent.prototype.onCapacityCountChange = function (count) {
                    if (count > this.maxCapacityCount) {
                        this.maxCapacityCount = count;
                    }
                };
                ClusterComponent.prototype.onHighlightedReplicaChange = function (replica) {
                    this.highlightedReplica = replica;
                };
                ClusterComponent.prototype.expandApplications = function () {
                    this.applicationsExpanded = !this.applicationsExpanded;
                    for (var _i = 0, _a = this.nodes; _i < _a.length; _i++) {
                        var node = _a[_i];
                        node.applicationsExpanded = this.applicationsExpanded;
                    }
                };
                ClusterComponent.prototype.expandServices = function () {
                    this.servicesExpanded = !this.servicesExpanded;
                    for (var _i = 0, _a = this.nodes; _i < _a.length; _i++) {
                        var node = _a[_i];
                        node.servicesExpanded = this.servicesExpanded;
                    }
                };
                return ClusterComponent;
            }());
            __decorate([
                core_1.ViewChild("container"),
                __metadata("design:type", core_1.ElementRef)
            ], ClusterComponent.prototype, "container", void 0);
            ClusterComponent = __decorate([
                core_1.Component({
                    selector: 'cluster-component',
                    templateUrl: 'app/components/cluster.component.html',
                    styleUrls: ['app/components/cluster.component.css'],
                    directives: [node_component_1.NodeComponent]
                }),
                __metadata("design:paramtypes", [data_service_1.DataService,
                    router_1.Router])
            ], ClusterComponent);
            exports_1("ClusterComponent", ClusterComponent);
        }
    };
});
//# sourceMappingURL=cluster.component.js.map