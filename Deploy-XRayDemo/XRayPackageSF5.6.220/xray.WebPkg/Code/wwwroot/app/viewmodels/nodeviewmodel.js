System.register(["./viewmodel"], function (exports_1, context_1) {
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
    var viewmodel_1, NodeViewModel;
    return {
        setters: [
            function (viewmodel_1_1) {
                viewmodel_1 = viewmodel_1_1;
            }
        ],
        execute: function () {
            NodeViewModel = (function (_super) {
                __extends(NodeViewModel, _super);
                function NodeViewModel(name, nodeType, status, health, upTime, address, faultDomain, upgradeDomain, applicationsExpanded, servicesExpanded) {
                    var _this = _super.call(this, name) || this;
                    _this.name = name;
                    _this.nodeType = nodeType;
                    _this.status = status;
                    _this.health = health;
                    _this.upTime = upTime;
                    _this.address = address;
                    _this.faultDomain = faultDomain;
                    _this.upgradeDomain = upgradeDomain;
                    _this.applicationsExpanded = applicationsExpanded;
                    _this.servicesExpanded = servicesExpanded;
                    return _this;
                }
                NodeViewModel.prototype.copyFrom = function (other) {
                    this.name = other.name;
                    this.nodeType = other.nodeType;
                    this.health = other.health;
                    this.status = other.status;
                    this.upTime = other.upTime;
                    this.address = other.address;
                    this.faultDomain = other.faultDomain;
                    this.upgradeDomain = other.upgradeDomain;
                };
                return NodeViewModel;
            }(viewmodel_1.ViewModel));
            exports_1("NodeViewModel", NodeViewModel);
        }
    };
});
//# sourceMappingURL=nodeviewmodel.js.map