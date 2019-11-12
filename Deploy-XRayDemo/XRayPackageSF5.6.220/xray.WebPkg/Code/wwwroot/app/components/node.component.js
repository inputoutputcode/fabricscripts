System.register(["angular2/core", "./../viewmodels/nodecapacityviewmodel", "./../viewmodels/clustercapacityviewmodel", "./../viewmodels/deployedapplicationviewmodel", "./../viewmodels/deployedserviceviewmodel", "./../viewmodels/deployedreplicaviewmodel", "./../viewmodels/list", "./../services/data.service", "./../directives/nodecapacityinfo.directive"], function (exports_1, context_1) {
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
    var core_1, nodecapacityviewmodel_1, clustercapacityviewmodel_1, deployedapplicationviewmodel_1, deployedserviceviewmodel_1, deployedreplicaviewmodel_1, list_1, data_service_1, nodecapacityinfo_directive_1, NodeComponent;
    return {
        setters: [
            function (core_1_1) {
                core_1 = core_1_1;
            },
            function (nodecapacityviewmodel_1_1) {
                nodecapacityviewmodel_1 = nodecapacityviewmodel_1_1;
            },
            function (clustercapacityviewmodel_1_1) {
                clustercapacityviewmodel_1 = clustercapacityviewmodel_1_1;
            },
            function (deployedapplicationviewmodel_1_1) {
                deployedapplicationviewmodel_1 = deployedapplicationviewmodel_1_1;
            },
            function (deployedserviceviewmodel_1_1) {
                deployedserviceviewmodel_1 = deployedserviceviewmodel_1_1;
            },
            function (deployedreplicaviewmodel_1_1) {
                deployedreplicaviewmodel_1 = deployedreplicaviewmodel_1_1;
            },
            function (list_1_1) {
                list_1 = list_1_1;
            },
            function (data_service_1_1) {
                data_service_1 = data_service_1_1;
            },
            function (nodecapacityinfo_directive_1_1) {
                nodecapacityinfo_directive_1 = nodecapacityinfo_directive_1_1;
            }
        ],
        execute: function () {
            NodeComponent = (function () {
                function NodeComponent(changeDetector, dataService) {
                    this.changeDetector = changeDetector;
                    this.dataService = dataService;
                    this.DefaultCapacitySize = 500;
                    this.NodeHeaderHeight = 120;
                    this.capacityCountChange = new core_1.EventEmitter();
                    this.selectedCapacityChange = new core_1.EventEmitter();
                    this.highlightedReplicaChange = new core_1.EventEmitter();
                    // element spacing in pixel values. 
                    // Margin is outer spacing: margin-top + margin-bottom
                    // PaddingAndBorder is inner spacing: padding-top + padding-bottom + border-width * 2
                    // these are not computed at runtime so they need to match CSS set on the corresponding elements.
                    this.nodeMargin = 6;
                    this.nodePaddingAndBorder = 6;
                    this.applicationMargin = 4;
                    this.applicationPaddingAndBorder = 2;
                    this.serviceMargin = 2;
                    this.servicePaddingAndBorder = 2;
                    this.replicaMargin = 0;
                    this.nodeCapacities = [];
                    this.applications = [];
                }
                NodeComponent.prototype.ngOnChanges = function (changes) {
                    if (changes['capacityCount']) {
                        console.log(this.capacityCount);
                        this.nodeHeaderHeight = this.NodeHeaderHeight + this.capacityCount * 7;
                    }
                    if (changes['applicationsExpanded']) {
                        for (var _i = 0, _a = this.applications; _i < _a.length; _i++) {
                            var appView = _a[_i];
                            appView.expanded = this.applicationsExpanded;
                        }
                    }
                    if (changes['servicesExpanded']) {
                        for (var _b = 0, _c = this.applications; _b < _c.length; _b++) {
                            var appView = _c[_b];
                            for (var _d = 0, _e = appView.services; _d < _e.length; _d++) {
                                var serviceView = _e[_d];
                                serviceView.expanded = this.servicesExpanded;
                            }
                        }
                    }
                    if (changes['selectedClusterCapacity']) {
                        for (var _f = 0, _g = this.applications; _f < _g.length; _f++) {
                            var appView = _g[_f];
                            appView.selectedMetric = this.getSelectedMetricValue(appView.application.metrics);
                            for (var _h = 0, _j = appView.services; _h < _j.length; _h++) {
                                var serviceView = _j[_h];
                                serviceView.selectedMetric = this.getSelectedMetricValue(serviceView.service.metrics);
                                for (var _k = 0, _l = serviceView.replicas; _k < _l.length; _k++) {
                                    var replicaView = _l[_k];
                                    replicaView.selectedMetric = this.getSelectedMetricValue(replicaView.replica.metrics);
                                }
                            }
                        }
                    }
                    if (changes['selectedColors']) {
                        for (var _m = 0, _o = this.applications; _m < _o.length; _m++) {
                            var appView = _o[_m];
                            appView.selectedClass = this.getSelectedColors(appView.application);
                            for (var _p = 0, _q = appView.services; _p < _q.length; _p++) {
                                var serviceView = _q[_p];
                                serviceView.selectedClass = this.getSelectedColors(serviceView.service);
                                for (var _r = 0, _s = serviceView.replicas; _r < _s.length; _r++) {
                                    var replicaView = _s[_r];
                                    replicaView.selectedClass = this.getSelectedColors(replicaView.replica);
                                }
                            }
                        }
                    }
                    if (changes['highlightedReplica']) {
                        for (var _t = 0, _u = this.applications; _t < _u.length; _t++) {
                            var appView = _u[_t];
                            for (var _v = 0, _w = appView.services; _v < _w.length; _v++) {
                                var serviceView = _w[_v];
                                for (var _x = 0, _y = serviceView.replicas; _x < _y.length; _x++) {
                                    var replicaView = _y[_x];
                                    replicaView.highlighted = replicaView.replica.partitionId + serviceView.service.name == this.highlightedReplica;
                                }
                            }
                        }
                    }
                    this.computeElementHeights();
                };
                NodeComponent.prototype.ngOnInit = function () {
                    var _this = this;
                    this.nodeCapacitySubscription = this.dataService.getNodeCapacity(this.nodeName).subscribe(function (result) {
                        if (!result) {
                            return;
                        }
                        var currentCount = _this.nodeCapacities.length;
                        list_1.List.updateList(_this.nodeCapacities, result.map(function (x) {
                            return new nodecapacityviewmodel_1.NodeCapacityViewModel(x.isCapacityViolation, x.name, x.bufferedCapacity, x.capacity, x.load, x.remainingBufferedCapacity, x.remainingCapacity);
                        }));
                        _this.computeElementHeights();
                        _this.changeDetector.markForCheck();
                        if (currentCount != _this.nodeCapacities.length) {
                            _this.capacityCountChange.emit(_this.nodeCapacities.length);
                        }
                    }, function (error) { return console.log("error from observable: " + error); });
                    this.applicationSubscription = this.dataService.getApplicationModels(this.nodeName, function () { return _this.selectedApplicationTypes.filter(function (x) { return !x.selected; }).map(function (x) { return x.name; }); }).subscribe(function (result) {
                        if (!result) {
                            return;
                        }
                        list_1.List.updateList(_this.applications, result.map(function (x) {
                            return new deployedapplicationviewmodel_1.DeployedApplicationViewModel(true, _this.getSelectedMetricValue(x.application.metrics), _this.getSelectedColors(x.application), x.application, x.services.map(function (y) {
                                return new deployedserviceviewmodel_1.DeployedServiceViewModel(true, _this.getSelectedMetricValue(y.service.metrics), _this.getSelectedColors(y.service), x.application.name, y.service, y.replicas.map(function (z) {
                                    return new deployedreplicaviewmodel_1.DeployedReplicaViewModel(false, _this.getSelectedMetricValue(z.metrics), _this.getSelectedColors(z), z.role ? z.role.toLowerCase() : 'unknown', z);
                                }));
                            }));
                        }));
                        _this.computeElementHeights();
                        _this.changeDetector.markForCheck();
                    }, function (error) { return console.log("error from observable: " + error); });
                };
                NodeComponent.prototype.ngOnDestroy = function () {
                    if (this.applicationSubscription) {
                        this.applicationSubscription.unsubscribe();
                    }
                    if (this.nodeCapacitySubscription) {
                        this.nodeCapacitySubscription.unsubscribe();
                    }
                };
                NodeComponent.prototype.onCapacityClick = function (name) {
                    this.selectedCapacityChange.emit(name);
                };
                NodeComponent.prototype.onReplicaMouseOver = function (name) {
                    this.highlightedReplicaChange.emit(name);
                };
                NodeComponent.prototype.onReplicaMouseLeave = function () {
                    this.highlightedReplicaChange.emit('');
                };
                NodeComponent.prototype.getPercentage = function (item, cap) {
                    if (cap === void 0) { cap = false; }
                    if (!item)
                        return '0';
                    var capacity = item.capacity > 0 ? item.capacity : this.selectedClusterCapacity.load;
                    var result = capacity > 0 ? item.load / capacity * 100 : 0;
                    if (cap && result > 100.0) {
                        return '100.0';
                    }
                    return result.toFixed(1);
                };
                NodeComponent.prototype.getSelectedMetricValue = function (metrics) {
                    var _this = this;
                    if (this.selectedClusterCapacity) {
                        var metric = metrics.find(function (x) { return x.name == _this.selectedClusterCapacity.name; });
                        if (metric) {
                            return metric.value;
                        }
                    }
                    return 0;
                };
                NodeComponent.prototype.getSelectedColors = function (model) {
                    var colors;
                    switch (this.selectedColors) {
                        case "status":
                            colors = model.status;
                            break;
                        case "health":
                            colors = model.healthState;
                            break;
                    }
                    return colors
                        ? colors.toLowerCase()
                        : 'unknown';
                };
                NodeComponent.prototype.computeElementHeights = function () {
                    var _this = this;
                    if (!this.selectedClusterCapacity) {
                        return;
                    }
                    this.selectedNodeCapacity = this.nodeCapacities.find(function (x) { return x.name == _this.selectedClusterCapacity.name; });
                    if (this.selectedNodeCapacity) {
                        var nodeCapacity;
                        var nodeContainerSize;
                        if (this.selectedNodeCapacity.capacity <= 0) {
                            this.elementHeight = -1; // lets the browser auto scale height  
                            nodeCapacity = this.DefaultCapacitySize / 20;
                            nodeContainerSize = this.DefaultCapacitySize * this.scaleFactor;
                        }
                        else {
                            this.elementHeight = Math.max(0, (this.selectedNodeCapacity.capacity * this.scaleFactor) - this.nodeMargin);
                            nodeCapacity = this.selectedNodeCapacity.capacity;
                            nodeContainerSize = Math.max(0, this.elementHeight - this.nodePaddingAndBorder);
                        }
                        for (var _i = 0, _a = this.applications; _i < _a.length; _i++) {
                            var appView = _a[_i];
                            if (appView.selectedMetric <= 0) {
                                continue;
                            }
                            appView.elementHeight =
                                Math.max(0, ((appView.selectedMetric / nodeCapacity) * nodeContainerSize) - this.applicationMargin);
                            for (var _b = 0, _c = appView.services; _b < _c.length; _b++) {
                                var serviceView = _c[_b];
                                if (serviceView.selectedMetric <= 0) {
                                    continue;
                                }
                                serviceView.elementHeight =
                                    Math.max(0, ((serviceView.selectedMetric / appView.selectedMetric) * (appView.elementHeight - this.applicationPaddingAndBorder)) - this.serviceMargin);
                                for (var _d = 0, _e = serviceView.replicas; _d < _e.length; _d++) {
                                    var replicaView = _e[_d];
                                    if (replicaView.selectedMetric <= 0) {
                                        continue;
                                    }
                                    replicaView.elementHeight =
                                        Math.max(0, ((replicaView.selectedMetric / serviceView.selectedMetric) * (serviceView.elementHeight - this.servicePaddingAndBorder)) - this.replicaMargin);
                                }
                            }
                        }
                    }
                };
                return NodeComponent;
            }());
            __decorate([
                core_1.Output(),
                __metadata("design:type", core_1.EventEmitter)
            ], NodeComponent.prototype, "capacityCountChange", void 0);
            __decorate([
                core_1.Output(),
                __metadata("design:type", core_1.EventEmitter)
            ], NodeComponent.prototype, "selectedCapacityChange", void 0);
            __decorate([
                core_1.Output(),
                __metadata("design:type", core_1.EventEmitter)
            ], NodeComponent.prototype, "highlightedReplicaChange", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", String)
            ], NodeComponent.prototype, "highlightedReplica", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", Number)
            ], NodeComponent.prototype, "capacityCount", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", clustercapacityviewmodel_1.ClusterCapacityViewModel)
            ], NodeComponent.prototype, "selectedClusterCapacity", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", Number)
            ], NodeComponent.prototype, "scaleFactor", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", Boolean)
            ], NodeComponent.prototype, "applicationsExpanded", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", Boolean)
            ], NodeComponent.prototype, "servicesExpanded", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", String)
            ], NodeComponent.prototype, "selectedColors", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", Array)
            ], NodeComponent.prototype, "selectedApplicationTypes", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", String)
            ], NodeComponent.prototype, "nodeName", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", String)
            ], NodeComponent.prototype, "nodeType", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", String)
            ], NodeComponent.prototype, "health", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", String)
            ], NodeComponent.prototype, "status", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", String)
            ], NodeComponent.prototype, "upTime", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", String)
            ], NodeComponent.prototype, "address", void 0);
            NodeComponent = __decorate([
                core_1.Component({
                    selector: 'node-component',
                    templateUrl: 'app/components/node.component.html',
                    styleUrls: ['app/components/node.component.css'],
                    changeDetection: core_1.ChangeDetectionStrategy.OnPush,
                    directives: [nodecapacityinfo_directive_1.NodeCapacityInfoDirective]
                }),
                __metadata("design:paramtypes", [core_1.ChangeDetectorRef,
                    data_service_1.DataService])
            ], NodeComponent);
            exports_1("NodeComponent", NodeComponent);
        }
    };
});
//# sourceMappingURL=node.component.js.map