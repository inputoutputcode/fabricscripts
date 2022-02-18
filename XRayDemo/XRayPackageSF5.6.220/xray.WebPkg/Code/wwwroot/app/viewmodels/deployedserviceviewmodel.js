System.register(["./viewmodel", "./list"], function (exports_1, context_1) {
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
    var __moduleName = context_1 && context_1.id;
    var viewmodel_1, list_1, DeployedServiceViewModel;
    return {
        setters: [
            function (viewmodel_1_1) {
                viewmodel_1 = viewmodel_1_1;
            },
            function (list_1_1) {
                list_1 = list_1_1;
            }
        ],
        execute: function () {
            DeployedServiceViewModel = (function (_super) {
                __extends(DeployedServiceViewModel, _super);
                function DeployedServiceViewModel(expanded, selectedMetric, selectedClass, applicationName, service, replicas) {
                    var _this = _super.call(this, service.name) || this;
                    _this.expanded = expanded;
                    _this.selectedMetric = selectedMetric;
                    _this.selectedClass = selectedClass;
                    _this.applicationName = applicationName;
                    _this.service = service;
                    _this.replicas = replicas;
                    _this.shortName = service.name.replace(applicationName + "/", "");
                    return _this;
                }
                DeployedServiceViewModel.prototype.copyFrom = function (other) {
                    this.service = other.service;
                    this.selectedMetric = other.selectedMetric;
                    this.selectedClass = other.selectedClass;
                    if (!this.replicas) {
                        this.replicas = [];
                    }
                    list_1.List.updateList(this.replicas, other.replicas);
                };
                return DeployedServiceViewModel;
            }(viewmodel_1.ViewModel));
            exports_1("DeployedServiceViewModel", DeployedServiceViewModel);
        }
    };
});
//# sourceMappingURL=deployedserviceviewmodel.js.map