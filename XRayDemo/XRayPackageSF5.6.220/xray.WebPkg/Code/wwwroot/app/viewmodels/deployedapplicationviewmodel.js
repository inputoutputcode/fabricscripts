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
    var viewmodel_1, list_1, DeployedApplicationViewModel;
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
            DeployedApplicationViewModel = (function (_super) {
                __extends(DeployedApplicationViewModel, _super);
                function DeployedApplicationViewModel(expanded, selectedMetric, selectedClass, application, services) {
                    var _this = _super.call(this, application.name) || this;
                    _this.expanded = expanded;
                    _this.selectedMetric = selectedMetric;
                    _this.selectedClass = selectedClass;
                    _this.application = application;
                    _this.services = services;
                    _this.shortName = application.name.replace("fabric:/", "");
                    return _this;
                }
                DeployedApplicationViewModel.prototype.copyFrom = function (other) {
                    this.application = other.application;
                    this.selectedMetric = other.selectedMetric;
                    this.selectedClass = other.selectedClass;
                    if (!this.services) {
                        this.services = [];
                    }
                    list_1.List.updateList(this.services, other.services);
                };
                return DeployedApplicationViewModel;
            }(viewmodel_1.ViewModel));
            exports_1("DeployedApplicationViewModel", DeployedApplicationViewModel);
        }
    };
});
//# sourceMappingURL=deployedapplicationviewmodel.js.map